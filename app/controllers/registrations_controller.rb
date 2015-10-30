class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js, :json

  def create
    @user = User.create(user_params)

    if @user.valid?
      Rails.logger.info "------------------------------------Sign up successfull "
    else
      Rails.logger.info "------------------------------------Sign up fail "
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
