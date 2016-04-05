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
  enum schedule_type: [:ongoing, :date_range]
  enum card_expiration_month: [:january, :february, :march, :april, :may, :june, :july,
                               :august, :september, :october, :november, :december]
  enum status: [:waiting, :accepted, :denied, :engaged, :paused, :stopped]

  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------

  attr_accessor :facebook_error

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
  has_one :brand_payment, dependent: :destroy

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :cost, :numericality => { :greater_than_or_equal_to => 0 }, allow_blank: true
  validates :card_number, credit_card_number: true, allow_blank: true
  validates :sender_id, :receiver_id, :name, presence: true
  validates :card_expiration_month, :card_expiration_year, presence: true, on: :update
  validates :name,
            uniqueness: { message: 'of the Campaign is already exist. Please try another Campaign Name.',
                          case_sensitive: false }

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
  scope :engaged_campaigns_for, ->(user) { where(status: [self.statuses[:engaged],self.statuses[:paused],self.statuses[:stopped]], receiver: user).where('end_date > ?', DateTime.now).order('id DESC') }
  # brand's campaigns
  scope :engaged_campaigns_from, ->(user) { where(status: [self.statuses[:engaged],self.statuses[:paused],self.statuses[:stopped]], sender: user).where('end_date > ?', DateTime.now).order('id DESC') }

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
      created_at.strftime('%I:%M %P')
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
    if self.post_type == 'profile_photo' || self.post_type == 'cover_photo'
      if self[:end_date].present? && (self[:end_date] < self[:start_date])
        errors[:End] << 'Date must be greater than Start Date'
        return false
      end
    end
    return true
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

  def get_start_time
    if profile_photo? || cover_photo?
      start_date.strftime('%I:%M')
    else
      'NA'
    end
  end

  def get_end_time
    if profile_photo? || cover_photo?
      end_date.strftime('%I:%M')
    else
      'NA'
    end
  end

  def get_start_date
    if start_date?
      start_date.strftime('%d-%m-%y')
    else
      'NA'
    end
  end

  def get_end_date
    if end_date?
      end_date.strftime('%d-%m-%y')
    else
      'NA'
    end
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

  def self.stop_expire_campaigns
    Campaign.where('schedule_type = ? AND end_date < ?', Campaign.schedule_types[:date_range], DateTime.now).each do |campaign|
      campaign.update_column(:status, Campaign.statuses[:stopped])
    end
  end

  private

  # Start Date : #{self.get_start_date}
  # End Date : #{self.get_end_date}
  # Start Time : #{self.get_start_time}
  # End Time : #{self.get_end_time}

  def first_message_body
    post_type_content = case post_type
                          when 'status_update' then "Status Message: #{campaign_content}"
                          when 'profile_photo' then "Profile Photo link: <a href=#{campaign_content} target='_blank'> Image </a>"
                          when 'cover_photo' then "Cover Photo link: <a href=#{campaign_content} target='_blank'> Image </a>"
                          when 'video_post' then  "Video link: <a href=#{campaign_content} target='_blank'> Video </a>"
                          when 'photo_post' then "Photo link: <a href=#{campaign_content} target='_blank'> Image </a>"
                        end

    if self.post_type == 'profile_photo' || self.post_type == 'cover_photo'
      campaign_heading = ''
      campaign_description = ''
      end_date = "#{self.end_date.try(:strftime, '%d-%m-%Y %I:%M %P') || 'NA'}"
    else
      campaign_heading = "Campaign Heading : #{self.headline.present? ? self.headline : 'NA'}"
      campaign_description = "Campaign Description : #{self.text.present? ? self.text : 'NA'}"
      end_date = 'NA'
    end

    <<MESSAGE
      Hi #{self.receiver.first_name},

      I'd like to make you an offer. Here are the campaign details:

      Brand Name: <a href='/#{self.sender.id}/show_user' data-remote='true'>#{self.sender.full_name}</a>
      Campaign Name:  #{self.name}
      Type of Post : #{self.post_type.humanize}
      #{post_type_content}
      Start Date : #{self.start_date.try(:strftime, '%d-%m-%Y %I:%M %P') || 'NA'}
      End Date : #{end_date}
      Payment : #{self.cost} INR
      Facebook Account: #{self.facebook_account.name}

      #{campaign_heading}
      #{campaign_description}
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
