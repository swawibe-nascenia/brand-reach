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

  has_many :facebook_accounts, foreign_key: 'influencer_id', dependent: :destroy
  has_many :campaigns_sent, class_name: 'Campaign', foreign_key: 'sender_id', dependent: :destroy
  has_many :campaigns_received, class_name: 'Campaign', foreign_key: 'receiver_id', dependent: :destroy
  has_many :bank_accounts
  has_many :influencer_payments

  accepts_nested_attributes_for :facebook_accounts

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :email, presence: true
  validates_confirmation_of :password

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  after_save :generate_channel_name, :save_actual_country_state

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  scope :influencers, ->{ where( user_type: user_types[:influencer])}
  scope :brands, ->{ where( user_type: user_types[:brand])}

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def is_facebook_authenticate?
    return self.provider == 'facebook' && self.uid? && self.access_token?
  end

  def profile_picture(version = :thumb)
      self.image.present? ? self.image.url(version).to_s : ActionController::Base.helpers.asset_path('default_profile_picture.png')
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
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.facebook_profile_url = auth.info.link

      user.gender = case auth.info.gender
                      when 'male' then User.genders[:male]
                      when 'female' then User.genders[:female]
                      else  User.genders[:other]
                    end

      graph = InsightService.new(auth.credentials.token)
      user.remote_image_url = graph.get_profile_picture

      # user.country = auth.info.location

      if params[:brand]
        user.user_type= User.user_types[:brand]
      else
        user.user_type = User.user_types[:influencer]
      end
    end

    user.access_token = auth.credentials.token

    user
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # ----------------------------------------------------------------------
  # == Private == #
  # ----------------------------------------------------------------------
  private

  def generate_channel_name
    self.update_column(:channel_name, generate_channel_postfix) if self.channel_name.blank?
  end

  def generate_channel_postfix
    rand(36**15).to_s(36) + self.id.to_s
  end

  def save_actual_country_state
    self.update_column(:country_name, Carmen::Country.coded(self.country).name)
    self.update_column(:state_name, Carmen::Country.coded(self.country).subregions.coded(self.state).name )
  end

end
