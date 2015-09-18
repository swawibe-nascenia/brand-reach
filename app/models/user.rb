class User < ActiveRecord::Base

  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable, :omniauth_providers => [:facebook]

  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

  enum user_type: [:brand, :influencer]

  enum gender: [:male, :female, :other]

  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------
  attr_accessor :current_password


  # ----------------------------------------------------------------------
  # == File Uploader == #
  # ----------------------------------------------------------------------

  mount_uploader :image, ImageUploader

  # ----------------------------------------------------------------------
  # == Associations and Nested Attributes == #
  # ----------------------------------------------------------------------

  has_one :facebook, foreign_key: 'influencer_id', dependent: :destroy

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :email, presence: true
  validates_confirmation_of :password

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  scope :influencers, ->{ where( user_type: User.user_types[:influencer])}
  scope :brands, ->{ where( user_type: User.user_types[:brand])}

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def is_facebook_authenticate?
    return self.provider == 'facebook' && self.uid? && self.access_token?
  end

  # ----------------------------------------------------------------------
  # == Class methods == #
  # ----------------------------------------------------------------------

  # call this method to authenticate user by facebook
  def self.authenticate_user_by_facebook(auth, params)
    user = User.find_by(email: auth.info.email)

    # create new user if user not found_by email
    unless user
      Rails.logger.info '------------------------ user registration process initialize-------------'
      Rails.logger.info auth.info
      user = User.new({
                          provider: auth.provider,
                          uid: auth.uid,
                          email: auth.info.email,
                          password: Devise.friendly_token[0,20]
                      })

      user.name = auth.info.name
      user.image = auth.info.image
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name

      user.gender = case auth.info.gender
                      when 'male' then User.genders[:male]
                      when 'female' then User.genders[:female]
                      else  User.genders[:other]
                    end

      # user.country = auth.info.location

      if params[:brand]
        user.user_type= User.user_types[:brand]
      else
        user.user_type = User.user_types[:influencer]
      end
    end

    user.access_token = auth.credentials.token

    if auth.credentials && auth.credentials.expires_at
      user.token_expires_at = Time.at(auth.credentials.expires_at)
    else
      user.token_expires_at = 8.weeks.from_now
    end

    user
  end

  def self.add_facebook_to_user_account(auth, params)
    # me?fields=accounts
    user = User.find_by(id: params['user_id'].to_i)
    social_account = user.social_accounts.build(provider: auth.provider, uid: auth.uid, access_token: auth.credentials.token, token_expires_at: 8.weeks.from_now)

    social_account
  end

  def name
    "#{first_name} #{last_name}"
  end

  # ----------------------------------------------------------------------
  # == Private == #
  # ----------------------------------------------------------------------

end
