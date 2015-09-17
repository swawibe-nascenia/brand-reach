class SocialAccount < ActiveRecord::Base
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

  belongs_to :user

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :provider, :uid, presence: true
  validates_uniqueness_of :uid, :scope => :provider
  validates_uniqueness_of :provider, :scope => :user_id


  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------
end
