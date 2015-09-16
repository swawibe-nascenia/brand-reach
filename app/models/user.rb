class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable, :omniauth_providers => [:facebook]

  enum user_type: [:brand, :influencer]

  attr_accessor :current_password

  # call this method to authenticate user by facebook
  def self.authenticate_user_by_facebook(auth, params)
    user = User.find_by(email: auth.info.email)

    # create new user if user not found_by email
    unless user
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
      user.gender = auth.info.gender
      user.country =

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
    user = User.find_by(id: params[:user_id])

    user
  end

end
