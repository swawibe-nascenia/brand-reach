class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    authentication_params = request.env['omniauth.params']
    authentication_info =  request.env['omniauth.auth']

      @user = User.authenticate_user_by_facebook(authentication_info, authentication_params)

      if @user.save
        sign_in @user
        set_flash_message(:notice, :success, :kind => 'Facebook') if is_navigational_format?
        redirect_to profile_profile_index_path
      else
        Rails.logger.info(@user.errors.inspect)
        puts @user.errors.full_messages
        session['devise.facebook_data'] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
  end
end
