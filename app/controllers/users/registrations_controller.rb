class Users::RegistrationsController < Devise::RegistrationsController

  before_action :set_user, only: [:update_user_profile, :edit_user_profile]

  def edit_user_profile
    @user = User.find(params[:id])
  end

  def update_user_profile
    if @user.update(user_profile_params)
      flash[:success] = 'User information update success'
    end
  end

  private

  def set_user
    @user = User.find params[:id]
  end

  def user_profile_params
    params.require(:user).permit(:first_name, :last_name, :email, :company_name, :company_email,
                                 :industry, :phone, :street_address, :landmark, :city, :state,
                                  :country, :zip_code, :short_bio
                                )
  end

end
