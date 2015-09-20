class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    authentication_params = request.env['omniauth.params']
    authentication_info =  request.env['omniauth.auth']

    if authentication_params['add_facebook_to_account'] == 'true'
      social_account  = User.add_facebook_to_user_account(authentication_info, authentication_params)

      if social_account.save
        flash[:success] = 'Your social account has been added successfully'
        redirect_to profile_profile_index_path
      else
        flash[:error] = 'Social account adding has been fail'
        redirect_to profile_profile_index_path
      end

    else
      @user = User.authenticate_user_by_facebook(authentication_info, authentication_params)

      if @user.save
        sign_in @user
        set_flash_message(:notice, :success, :kind => 'Facebook') if is_navigational_format?
        redirect_to profile_profile_index_path
      else
        puts @user.errors.full_messages
        session['devise.facebook_data'] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    end
  end
end