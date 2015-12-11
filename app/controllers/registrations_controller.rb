class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js, :json

  def new
    redirect_to root_path
  end

  def create
    if  request.format.symbol == :html
      redirect_to root_path
    end
    @user = User.new(user_params)
    password = Devise.friendly_token.first(8)
    @user.password = password
    @user.password_confirmation = password
    @user.user_type = 0
    @user.status = User.statuses[:waiting]

    @success = true
    @messages = []

    if @user.save
      @messages << <<EOF
                        Your information submitted successfully.
                        When account activated we will notify you by email.
EOF
    else
      @messages = @user.errors.full_messages
      @success = false
    end

    Rails.logger.info "----------------user is -----------------------#{@user}------------------"
    respond_to do |format|
      format.js{ }
      format.html do
        flash[:notice] = @messages
        redirect_to new_user_registration_path

      end
    end
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :position, :company_name, :phone, :short_bio)
  end
end
