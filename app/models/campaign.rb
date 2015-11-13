class Campaign < ActiveRecord::Base
  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------
  # include validations for loading card number validations

  include ActiveModel::Validations

  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

  enum post_type: [:status_update, :profile_photo, :cover_photo, :video_post]
  enum schedule_type: [:daily, :date_range]
  enum card_expiration_month: [:january, :february, :march, :april, :may, :june, :july, :august, :september, :october, :november, :december]
  enum status: [:waiting, :accepted, :denied]

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

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  before_save :date_validation

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  scope :active_campaigns_for,  ->(user) { where(status: self.statuses[:accepted], receiver: user) }
  scope :active_campaigns_from,  ->(user) { where(status: self.statuses[:accepted], sender: user) }

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
      created_at.strftime('%H:%M%P')
    else
      created_at.strftime('%d-%m-%Y')
    end
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

  private

  def first_message_body
    <<MESSAGE
    <p class='first-message'>
      You have sent the following campaign request. Waiting for the influencers response.

      <strong>Campaign Name:</strong> #{self.name}
      <strong>Type of Post:</strong> #{self.post_type.camelize}
      <strong>Start Date:</strong> #{self.start_date}
      <strong>End Date:</strong> #{self.end_date}
      <strong>Payment:</strong> #{self.cost}$

      <strong>Campaign Heading:</strong> #{self.headline}
      <strong>Campaign Description:</strong> #{self.text}
    </p>
MESSAGE
  end
end
