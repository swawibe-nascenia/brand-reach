class PasswordsController < Devise::PasswordsController
  respond_to :js, :html

  def create
   temp_user = User.where(email: params[:user]['email'],
                          user_type: [User.user_types[:brand],
                                      User.user_types[:admin],
                                      User.user_types[:super_admin]
                                      ], status: User.statuses[:active]).first
   @password_reset_send_success = false
   @messages = []

   if temp_user
     if successfully_sent?(User.send_reset_password_instructions(resource_params))
       @password_reset_send_success = true
       @messages << 'Password reset info sent to your email. Please check your mail.'
     else
       @messages << 'Something went wrong. Please try again.'
       flash[:success] = 'Something went wrong. Please try again.'
     end
   else
     @messages << 'This email address was not found.'
     flash[:error] = 'This email address was not found.'
   end

   respond_to do |format|
     format.html{ redirect_to new_user_password_path }
     format.js{}
   end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message(:notice, flash_message) if is_flashing_format?
        sign_in(resource_name, resource)
      else
        set_flash_message(:notice, :updated_not_active) if is_flashing_format?
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      if resource.errors.messages[:reset_password_token]
        resource.errors.messages.delete(:reset_password_token)
        resource.errors.messages[:password_reset_link] = ['has already been used']
      end
      respond_with resource
    end
  end

  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    root_url
  end
end