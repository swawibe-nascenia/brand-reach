class ProfileController < ApplicationController
  layout 'sidebar_header_layouts'
  before_action :set_user, only: [:profile, :update]

  respond_to :html

  def profile
    respond_with(@user)
  end

  def update
    # if @user.update_with_password(user_profile_params)

    if @user.update(user_profile_params)
      flash[:success] = 'User information update success'
    else
      flash[:error] = 'User information update fail'
    end

    redirect_to profile_profile_path
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
