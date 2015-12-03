class PasswordsController < Devise::PasswordsController
  respond_to :js, :html

  def create
    if request.format.html?
      super
    end

   temp_user = User.find_by_email(params[:user]['email'])
   @password_reset_send_success = false
   @messages = []

   if temp_user && temp_user.brand?
     if successfully_sent?(User.send_reset_password_instructions(resource_params))
       @password_reset_send_success = true
       @messages << 'Password reset info sent to your email. Please check your mail.'
     else
       @messages << 'Something went wrong. Please try again.'
     end
   else
     @messages << 'This e-mail ID was not found.'
   end
 end

  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    root_url
  end
end