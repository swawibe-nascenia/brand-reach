class PasswordsController < Devise::PasswordsController
  respond_to :js, :html

  def create
   temp_user = User.where(email: params[:user]['email'],
                          user_type: [User.user_types[:brand],
                                      User.user_types[:admin],
                                      User.user_types[:super_admin]
                                      ], verified: true, is_active: true).first
   @password_reset_send_success = false
   @messages = []

   if temp_user
     if successfully_sent?(User.send_reset_password_instructions(resource_params))
       @password_reset_send_success = true
       @messages << 'Password reset info sent to your email. Please check your mail.'
       flash[:success] = 'Password reset info sent to your email. Please check your mail.'
     else
       @messages << 'Something went wrong. Please try again.'
       flash[:success] = 'Something went wrong. Please try again.'
     end
   else
     @messages << 'This e-mail ID was not found.'
     flash[:success] = 'This e-mail ID was not found.'
   end
 end

  respond_to do |format|
    format.html{}
    format.js{}
  end
  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    root_url
  end
end