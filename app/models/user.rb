class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

	
	def self.from_omniauth(auth)
		puts auth
		user = User.find_by(provider: auth.provider, uid: auth.uid)
		if !user
			user = User.new({
				provider: auth.provider, 
				uid: auth.uid,
				email: auth.info.email,
				password: Devise.friendly_token[0,20]
			})
		end
    user.access_token = auth.credentials.token
    if auth.credentials && auth.credentials.expires_at
	    user.token_expires_at = Time.at(auth.credentials.expires_at)
	  else
	  	user.token_expires_at = 1.week.from_now
	  end
    user.name = auth.info.name
    user.image = auth.info.image
    user
	end

end
