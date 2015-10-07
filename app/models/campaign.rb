class Campaign < ActiveRecord::Base
  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------
  # include validations for loading card number validations

  include ActiveModel::Validations


  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

  enum post_type: [:post, :status, :profile_picture, :cover_picture]
  enum schedule_type: [:daily, :date_range]
  enum card_expiration_month: [:january, :february, :march, :april, :may, :june, :july, :august, :september, :october, :november, :december]

  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------


  # ----------------------------------------------------------------------
  # == File Uploader == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Associations and Nested Attributes == #
  # ----------------------------------------------------------------------

  has_many :messages
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :cost, :numericality => { :greater_than_or_equal_to => 0 }, allow_blank: true
  validates :card_number, credit_card_number: true, allow_blank: true
  validates :sender_id, :receiver_id, presence: true

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  before_save :date_validation

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def date_validation
    if self[:end_date].present? && ( self[:end_date] < self[:start_date] )
      errors[:End] << 'Date must be greater than Start Date'
      return false
    else
      return true
    end
  end

end
