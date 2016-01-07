class Campaign < ActiveRecord::Base
  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------
  # include validations for loading card number validations

  include ActiveModel::Validations

  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

  enum post_type: [:status_update, :profile_photo, :cover_photo, :video_post, :photo_post]
  enum schedule_type: [:daily, :date_range]
  enum card_expiration_month: [:january, :february, :march, :april, :may, :june, :july, :august, :september, :october, :november, :december]
  enum status: [:waiting, :accepted, :denied, :engaged]

  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == File Uploader == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Associations and Nested Attributes == #
  # ----------------------------------------------------------------------

  has_many :messages, dependent: :destroy
  belongs_to :facebook_account
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
  has_one :brand_payment

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :cost, :numericality => { :greater_than_or_equal_to => 0 }, allow_blank: true
  validates :card_number, credit_card_number: true, allow_blank: true
  validates :sender_id, :receiver_id, :name, :text, :headline, presence: true
  validates :card_expiration_month, :card_expiration_year, presence: true, on: :update
  validates :name, uniqueness: { message: 'of the Campaign is already exist. Please try another Campaign Name.', case_sensitive: false }

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  before_save :date_validation
  after_update :send_offer_update_pubnub_notification
  after_create :send_pubnub_notification

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------
  # influencer's campaigns
  scope :engaged_campaigns_for, ->(user) { where(status: self.statuses[:engaged], receiver: user).order('id DESC') }
  # brand's campaigns
  scope :engaged_campaigns_from, ->(user) { where(status: self.statuses[:engaged], sender: user).order('id DESC') }

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def fetch_insights
    if self.social_account_activity_id.blank?
      return
    end

    graph = InsightService.new(self.facebook_account.influencer.access_token)
    data = graph.get_post_info(self.social_account_activity_id)

    self.number_of_likes = data[:number_of_likes]
    self.number_of_post_reach = graph.get_post_reach(self.social_account_activity_id)
    self.number_of_comments = data[:number_of_comments]
    self.number_of_shares = data[:number_of_shares]

    self.save
  end

  def time
    if created_at.to_date == Date.today
      created_at.strftime('%I:%M%P')
    else
      created_at.strftime('%d-%m-%Y')
    end
  end

  def today_post?
    created_at.to_date == Date.today
  end

  def deny_undo_able?
    Time.now - denied_at <= 10
  end

  def date_validation
    if self[:end_date].present? && (self[:end_date] < self[:start_date])
      errors[:End] << 'Date must be greater than Start Date'
      return false
    else
      return true
    end
  end

  def create_first_message
    messages.create(sender_id: self.sender_id, receiver_id: self.receiver_id, body: first_message_body);
  end

  def deletable?
    waiting? || denied?
  end

  def messageable?
    accepted_offer = (accepted? || engaged?)
    active_offer = !deleted_by_influencer? &&  !deleted_by_brand?

    accepted_offer && active_offer && sender.active? && receiver.active?
  end
  # ----------------------------------------------------------------------
  # == Class methods == #
  # ----------------------------------------------------------------------

  def self.active_offers(user)
    if user.brand?
      user.campaigns_sent.where(deleted_by_brand: false)
    else
      user.campaigns_received.where(deleted_by_influencer: false, deleted_by_brand: false)
    end
  end

  def self.stared_offers(user)
    if user.brand?
      active_offers(user).where(starred_by_brand: true)
    else
      active_offers(user).where(starred_by_influencer: true)
    end
  end

  def self.fetch_all_insights
    Campaign.where('status = ? AND social_account_activity_id IS NOT NULL', self.statuses[:engaged]).each do |campaign|
      campaign.fetch_insights
    end
  end

  private

  def first_message_body
    post_type_content = case post_type
             when 'status_update' then "Status Message: #{campaign_content}"
             when 'profile_photo' then "Profile Photo link: <a href=#{campaign_content} target='_blank'> Image </a>"
             when 'cover_photo' then "Cover Photo link: <a href=#{campaign_content} target='_blank'> Image </a>"
             when 'video_post' then  "Video link: <a href=#{campaign_content} target='_blank'> Video </a>"
             when 'photo_post' then "Photo link: <a href=#{campaign_content} target='_blank'> Image </a>"
            end

    <<MESSAGE
      Hi #{self.receiver.first_name},

      I'd like to make you an offer. Here are the campaign details:

      Brand Name: <a href='/#{self.sender.id}/show_user' data-remote='true'>#{self.sender.full_name}</a>
      Campaign Name:  #{self.name}
      Type of Post : #{self.post_type.humanize}
      #{post_type_content}
      Start Date : #{self.start_date.strftime('%d-%m-%Y')}
      End Date : #{self.end_date.strftime('%d-%m-%Y')}
      Payment : #{self.cost} INR
      Facebook Account: #{self.facebook_account.name}

      Campaign Heading : #{self.headline}
      Campaign Description : #{self.text}
MESSAGE
  end

  def send_pubnub_notification
    subscriber_chanels = User.where(id: [ sender_id, receiver_id]).pluck(:channel_name)

    Rails.logger.info 'Send pubnub notification for offer creation'

    subscriber_chanels.each do |channel|
      Rails.logger.info "Send pubnub notification for offer creation to channel #{channel}"

      $pubnub_server_subscription.publish(
          :channel => channel,
          :message => {event: 'NEW_OFFER',
                       attributes: {
                           id: self.id,
                       }
          },
          callback: lambda{ |info| Rails.logger.info "Send message to pubnub channel #{info}" }
      )
    end
  end

  def send_offer_update_pubnub_notification
    subscriber_chanels = User.where(id: [ sender_id, receiver_id]).pluck(:channel_name)

    Rails.logger.info 'Send pubnub notification for offer update'

    subscriber_chanels.each do |channel|
      Rails.logger.info "Send pubnub notification for offer creation to channel #{channel}"

      $pubnub_server_subscription.publish(
          :channel => channel,
          :message => {event: 'OFFER_UPDATE',
                       attributes: {
                           id: self.id,
                       }
          },
          callback: lambda{ |info| Rails.logger.info "Send message to pubnub channel #{info}" }
      )
    end
  end
end
