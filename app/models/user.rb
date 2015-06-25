class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

	
	def self.from_omniauth(auth)
		puts auth
		puts '-------------------'
		puts auth['credentials'].expires_at
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
	    user.email = auth.info.email
	    user.access_token = auth.credentials.token
	    user.uid = auth.credentials.id
	    user.token_expires_at = Time.at(auth.credentials.expires_at)
	    user.password = Devise.friendly_token[0,20]
	    user.name = auth.info.name
	    user.image = auth.info.image
	  end
	end

end
# http://tech.pro/tutorial/1430/ruby-on-rails-4-authentication-with-facebook-and-omniauth