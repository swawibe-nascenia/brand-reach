class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    authentication_params = request.env['omniauth.params']
    authentication_info =  request.env['omniauth.auth']

    if authentication_params[:add_facebook_to_account]
      User.add_facebook_to_user_account(authentication_info, authentication_params)
    else
      @user = User.authenticate_user_by_facebook(authentication_info, authentication_params)

      if @user.save
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => 'Facebook') if is_navigational_format?
      else
        puts @user.errors.full_messages
        session['devise.facebook_data'] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    end
  end
end