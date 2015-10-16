class Offer < ActiveRecord::Base
  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------


  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

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

  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
  has_one :campaign

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :sender_id, :receiver_id, presence: true

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def time
    if created_at.to_date == Date.today
       created_at.strftime('%H:%M:%P')
    else
      created_at.strftime('%d:%m:%Y')
    end
  end

  def deny_undo_able?
    Time.now - denied_at <= 30
  end

  # ----------------------------------------------------------------------
  # == Class methods == #
  # ----------------------------------------------------------------------

  def self.get_active_offer(user)
    if user.brand?
      user.campaigns_sent.where(deleted_by_brand: false)
    else
      user.campaigns_received.where(deleted_by_influencer: false)
    end
  end

  def self.get_stared_offer(user)
    if user.brand?
      get_active_offer(user).where(starred_by_brand: true)
    else
      get_active_offer(user).where(starred_by_influencer: true)
    end
  end

end
