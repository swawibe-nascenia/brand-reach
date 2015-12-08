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

  enum user_type: [:brand, :influencer, :admin, :super_admin]

  enum gender: [:male, :female, :other]

  Industry = ['Health and Beauty', 'Technology', 'Startups', 'Internet', 'Food', 'Restaurants', 'Automobile']

  BRAND_PROFILE_COMPLETENESS = [:company_name, :company_email, :industry, :phone, :street_address,
                                :city, :state, :country, :zip_code, :short_bio, :first_name, :last_name]

  INFLUENCER_PROFILE_COMPLETENESS = [:industry, :phone, :street_address,
                                     :city, :state, :country, :zip_code, :short_bio, :first_name, :last_name]

  FACEBOOK_ACCOUNT_COMPLETENESS = [:status_update_cost, :profile_photo_cost, :cover_photo_cost, :video_post_cost]

  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------

  attr_accessor :current_password,:crop_x, :crop_y, :crop_w, :crop_h

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
  has_many :contact_uses
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'

  accepts_nested_attributes_for :facebook_accounts

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :email, presence: true, uniqueness: true
  validates :phone, format: { with: /(^[\+]?[0-9]+[-]?[0-9]+[-]?[0-9]+$)/, message: 'Number format is not correct.' }, if: 'phone.present?'
  validates_confirmation_of :password
  validates :zip_code, zipcode: { country_code_attribute: :country }, if: 'zip_code.present?'
  validates :short_bio, length: { maximum: 1000 }
  validates :first_name, :last_name, :company_name, :industry, :phone, :street_address, :city, :zip_code, :country,
            :company_email, :short_bio, presence: true, on: :update, if: Proc.new{|u| u.brand? || u.influencer?}


  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------
  after_create :generate_channel_name, :send_mail
  after_save :save_actual_country_state
  after_update :update_profile_completion_status

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  scope :influencers, ->{ where( user_type: user_types[:influencer], is_active: true)}
  scope :brands, ->{ where( user_type: user_types[:brand], is_active: true, verified: true)}

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def active_facebook_accounts
    facebook_accounts.where(is_active: true)
  end

  def calculate_max_followers
    active_facebook_accounts.pluck(:number_of_followers).max
  end

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
                          company_email: auth.info.email,
                          password: Devise.friendly_token[0,20],
                          is_active: true,
                          user_type: User.user_types[:influencer],
                          verified: true
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
    end

    user.access_token = auth.credentials.token
    user
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def location
    "#{state_name}, #{country_name}"
  end

  def unread_messages
    self.received_messages.where(read: 0).count
  end

  # update user account completion according to passing boolean status
  def update_profile_complete(status)
    update_column(:profile_complete, status)
  end

  # campaign
  def campaign_receivable?()
    if brand?

    else
      false
    end
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
    self.update_column(:country_name, Carmen::Country.coded(self.country).name) if self.country.present?
    self.update_column(:state_name, Carmen::Country.coded(self.country).subregions.coded(self.state).name ) if self.country.present? && self.state.present?
  end

  def update_profile_completion_status
    if self.influencer?
       if active_facebook_accounts.blank?
         Rails.logger.info  "===================No Facebook Account is connected"
         update_column(:profile_complete, false)
         return
       end

      active_facebook_accounts.each do |facebook_account|
        FACEBOOK_ACCOUNT_COMPLETENESS.each do |field|
          unless facebook_account.send("#{field}").present?
            update_column(:profile_complete, false)
            Rails.logger.info  "=================== Facebook Account #{facebook_account.name} is incomplete for field #{field}"
            return
          end
        end
      end

      INFLUENCER_PROFILE_COMPLETENESS.each do |field|
        unless send("#{field}?")
          update_column(:profile_complete, false)
          Rails.logger.info  "=====================================Checking present field fail for #{field}"
          return
        end
      end

    else
      BRAND_PROFILE_COMPLETENESS.each do |field|
        unless send("#{field}?")
          update_column(:profile_complete, false)
          Rails.logger.info  "=====================================Checking present field fail for #{field}"
          return
        end
      end
    end

    Rails.logger.info "Successfully user #{self} completed his profile"
    update_column(:profile_complete, true)
  end

  def send_mail
    CampaignMailer.sing_up_notification_to_admin(self).deliver_now if brand?
  end

end
