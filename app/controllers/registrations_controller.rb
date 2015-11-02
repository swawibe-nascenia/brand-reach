class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js, :json

  def create
    @user = User.create(user_params.except(:user_type))

    @success = true
    @message = ''

    if @user.valid?
      @user.update_columns({ user_type: params[:user][:user_type], verified: false })

      respond_to do |format|
        flash[:success] = <<EOF
                             Your information submitted successfully.
                             When account activate we will notify to you email.
EOF
        format.js{  }
        format.html { redirect_to new_user_registration_path  }
      end
      Rails.logger.info "------------------------------------Sign up successfull "
    else
      Rails.logger.info "------------------------------------Sign up fail #{@user.errors.messages}"
      @success = false
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :user_type)
  end
end
