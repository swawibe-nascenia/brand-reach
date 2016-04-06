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
  # user status
  #              signup -> user has just signed up and needs to add at least one page before they become active
  #              active -> Currently active user (showed on explore page, can communicate),
  #              waiting -> Brand submit info to site need verified by brandreach to activate account
  #              invited -> Invited by admin (only showed on admin brand invitation page)
  #              suspended -> Suspended by admin, shows no where
  #              inactive -> Deactivated by user, shows no where
  enum status: [:active, :invited, :waiting, :inactive, :suspended, :in_limbo]
  enum gender: [:male, :female, :other]

  Industry = ['Health and Beauty', 'Technology', 'Startups', 'Internet', 'Food', 'Restaurants', 'Automobile']

  BRAND_PROFILE_COMPLETENESS = [
      :company_name,
      :company_email,
      :phone, :city,
      :state,
      :country,
      :zip_code,
      :short_bio,
      :first_name,
      :last_name
  ]

  INFLUENCER_PROFILE_COMPLETENESS = [
      :phone,
      :city,
      :state,
      :country,
      :zip_code,
      :short_bio,
      :first_name,
      :last_name
  ]

  FACEBOOK_ACCOUNT_COMPLETENESS = [:status_update_cost, :profile_photo_cost, :cover_photo_cost, :video_post_cost]

  MIN_LIKES_FOR_REGISTRATION = CONFIG[:min_fb_likes_for_registration]

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
  has_many :bank_accounts, dependent: :destroy
  has_many :influencer_payments, dependent: :destroy
  has_many :contact_uses, class_name: 'ContactUs', dependent: :destroy
  # has_many :contact_uses, class_name: 'ContactUs', dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'
  has_and_belongs_to_many :categories

  accepts_nested_attributes_for :facebook_accounts

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :email, presence: true
  validates :email, uniqueness: true, if: :uniqueness_of_email
  validates :uid, uniqueness: true, if: 'uid.present?'
  validates :phone, format: { with: /(^[\+]?[0-9]+[-]?[0-9]+[-]?[0-9]+$)/, message: 'Number format is not correct.' }, if: 'phone.present?'
  validates_confirmation_of :password
  # validates_length_of :password, :minimum => 6, :allow_blank => true
  validates :zip_code, zipcode: { country_code_attribute: :country }, if: 'zip_code.present?'
  validates :short_bio, length: { maximum: 1000 }
  validates :first_name, :last_name, :company_name, :phone, :city, :zip_code, :country, :state,
            :company_email, :short_bio, presence: true, on: :update, if: Proc.new{|u| u.brand? || u.influencer?}


  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------
  after_create :generate_channel_name
  after_save :save_actual_country_state
  after_update :update_profile_completion_status

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  scope :active_influencers, ->{ where( user_type: user_types[:influencer], status: User.statuses[:active])}
  scope :inactive_influencers, ->{ where( user_type: user_types[:influencer], status: User.statuses[:inactive])}
  scope :suspended_influencers, ->{ where( user_type: user_types[:influencer], status: User.statuses[:suspended])}
  scope :active_suspended_influencers, ->{ where( user_type: user_types[:influencer],
                                                  status: [
                                                      User.statuses[:active],
                                                      User.statuses[:suspended]
                                                  ]
  )}

  scope :active_brands, ->{ where( user_type: user_types[:brand], status: User.statuses[:active])}
  scope :inactive_brands, ->{ where( user_type: user_types[:brand],  status: User.statuses[:inactive])}
  scope :invited_brands, ->{ where( user_type: user_types[:brand],  status: User.statuses[:invited])}
  scope :waiting_brands, ->{ where( user_type: user_types[:brand],  status: User.statuses[:waiting])}
  scope :suspended_brands, ->{ where( user_type: user_types[:brand],  status: User.statuses[:suspended])}
  scope :active_suspended_brands, ->{ where( user_type: user_types[:brand],
                                             status: [
                                                 User.statuses[:active],
                                                 User.statuses[:suspended]
                                             ])}

  singleton_class.send(:alias_method, :influencers, :active_influencers)
  singleton_class.send(:alias_method, :brands, :active_brands)


  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def active_facebook_accounts
    facebook_accounts.where(is_active: true)
  end

  def calculate_max_followers
    active_facebook_accounts.pluck(:number_of_followers).sum
  end

  def is_facebook_authenticate?
    return self.provider == 'facebook' && self.uid? && self.access_token?
  end

  def profile_picture(version = :thumb)
    self.image.present? ? self.image.url(version).to_s : ActionController::Base.helpers.asset_path('default_profile_picture.png')
  end

  def uniqueness_of_email
    if self.brand?
      if User.find_by_email(self.email) && User.find_by_email(self.email).invited?
        errors.add(:email, ' activation link already sent. Please activate your account from email address')
        return false
      end
    end

    return true
  end

  # ----------------------------------------------------------------------
  # == Class methods == #
  # ----------------------------------------------------------------------

  # call this method to authenticate user by facebook
  def self.authenticate_user_by_facebook(auth, params)
    user = User.find_by(email: auth.info.email)

    # create new user if user not found_by email
    unless user
      graph = InsightService.new(auth.credentials.token)

      if graph.get_max_likes(auth.uid) < User::MIN_LIKES_FOR_REGISTRATION
        return false
      end

      Rails.logger.info '------------------------ user registration process initialize-------------'
      Rails.logger.info auth.info
      user = User.new({
                          provider: auth.provider,
                          uid: auth.uid,
                          email: auth.info.email,
                          company_email: auth.info.email,
                          password: Devise.friendly_token[0,20],
                          status: User.statuses[:in_limbo],
                          user_type: User.user_types[:influencer],
                      })

      user.name = auth.info.name
      user.first_name = if auth.info.middle_name
                          "#{auth.info.first_name} #{auth.info.middle_name}"
                        else
                          auth.info.first_name
                        end

      user.last_name = auth.info.last_name
      user.facebook_profile_url = auth.info.link

      user.gender = case auth.info.gender
                      when 'male' then User.genders[:male]
                      when 'female' then User.genders[:female]
                      else  User.genders[:other]
                    end

      user.remote_image_url = graph.get_profile_picture
    end

    if user.status == 'inactive'
      user.status = User.statuses[:active]
    end

    user.access_token = auth.credentials.token
    user
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def location
    "#{city}, #{state_name}, #{country_name}"
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

  # user object creation user friendly time
  def time
    if created_at.to_date == Date.today
      created_at.strftime('%I:%M %P')
    else
      created_at.strftime('%d-%m-%Y')
    end
  end

  # devise method override for skip validation during reset password
  def reset_password(new_password, new_password_confirmation)
    self.password = new_password
    self.password_confirmation = new_password_confirmation

    validates_presence_of     :password
    validates_confirmation_of :password
    validates_length_of       :password, within: Devise.password_length, allow_blank: true

    if errors.empty?
      clear_reset_password_token
      self.status = User.statuses[:active]
      save(validate: false)
    end
  end

  # =============== reset password token generate and save to user
  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc.next_week
    self.save(validate: false)
    raw
  end

  # return engage campaign
  def engaged_campaigns
    if brand?
      Campaign.engaged_campaigns_from(self)
    else
      Campaign.engaged_campaigns_for(self)
    end
  end

  def full_address
    address = ''
    address = address + street_address + ', ' if street_address.present?
    address = address + city + ', ' if city
    address = address + state_name + ', ' if state_name
    address = address + country_name if country_name
    address
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
    self.update_column(:name,  "#{first_name} #{last_name}")
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
    CampaignMailer.brand_invitation(self).deliver_now if brand? && invited?
  end

end
