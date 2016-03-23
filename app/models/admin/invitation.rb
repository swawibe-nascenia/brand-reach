class Admin::Invitation < ActiveRecord::Base
  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == File Uploader == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Associations and Nested Attributes == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------
  validates :email, uniqueness: true, if: :uniqueness_of_email_in_user_table

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  # after_create :send_invitation

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def full_name
    "#{first_name} #{last_name}"
  end

  # user object creation user friendly time
  def time
    if created_at.try(:to_date) == Date.today
      created_at.strftime('%H:%M%P')
    else
      created_at.try(:strftime, '%d-%m-%Y')

    end
  end

  # ----------------------------------------------------------------------
  # == Class methods == #
  # ----------------------------------------------------------------------

  private

  def uniqueness_of_email_in_user_table
    if User.find_by_email(self.email)
      errors.add(:email, ' address is already activated as a Brand or an Influencer in our portal. Please use another email')
      return false
    end
    return true
  end

  def send_invitation
    Rails.logger.info "=============== Send invitaions to callback ================"
    CampaignMailer.influencer_invitation(self).deliver_now
  end
end