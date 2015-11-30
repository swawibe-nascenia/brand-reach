class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    authentication_params = request.env['omniauth.params']
    authentication_info =  request.env['omniauth.auth']

      @user = User.authenticate_user_by_facebook(authentication_info, authentication_params)

      # Here Validation is false as when we are signing in with facebook for first time then User models validation will rise an presence true error. So for first time signing in we are bypassing it. But Validations will be check in Model.

      if @user.save(validate: false)
        sign_in @user
        set_flash_message(:notice, :success, :kind => 'Facebook') if is_navigational_format?
        if current_user.influencer? && current_user.profile_complete?
          insights_facebook_index_path
        else
          redirect_to profile_profile_index_path
        end
      else
        Rails.logger.info(@user.errors.inspect)
        puts @user.errors.full_messages
        session['devise.facebook_data'] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
  end
end
