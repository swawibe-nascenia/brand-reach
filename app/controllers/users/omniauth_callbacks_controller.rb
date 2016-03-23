class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    authentication_params = request.env['omniauth.params']
    authentication_info = request.env['omniauth.auth']

    @user = User.authenticate_user_by_facebook(authentication_info, authentication_params)

    unless @user
      return redirect_to sign_up_requirements_public_index_path
    end

    if @user.influencer?
      is_allowed = @user.in_limbo? || @user.active? || @user.inactive?
      if is_allowed
        if @user.save!(validate: false)
          sign_in @user
          set_flash_message(:notice, :success, :kind => 'Facebook') if is_navigational_format?
          if current_user.influencer? && current_user.profile_complete?
            redirect_to insights_facebook_index_path
          else
            redirect_to profile_profile_index_path
          end
        else
          Rails.logger.info(@user.errors.inspect)
          puts @user.errors.full_messages
          session['devise.facebook_data'] = request.env['omniauth.auth']
          redirect_to new_user_registration_url
        end
      else
        flash[:error] = 'Your account is suspended by admin. Please contact with admin for activation.'
        redirect_to root_path
      end
    else
      flash[:error] = 'Email has already been taken. Please sign in here.'
      redirect_to new_user_session_path
    end

  end
end
