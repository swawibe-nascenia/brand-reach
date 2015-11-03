class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js, :json

  def create
    @user = User.create(user_params.except(:user_type))

    @success = true
    message = []

    if @user.valid?
      @user.update_columns({ user_type: params[:user][:user_type], verified: false })
      message << <<EOF
                        Your information submitted successfully.
                        When account activated we will notify you by email.
EOF
      flash['notice'] = message
    else
      message = @user.errors.full_messages
      @success = false
      flash['error'] = message
    end

    Rails.logger.info "----------------user is -----------------------#{@user}------------------"
    respond_to do |format|
      format.js{ @user = @user }
      format.html do
        redirect_to new_user_registration_path
      end
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :user_type)
  end
end
