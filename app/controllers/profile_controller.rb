class ProfileController < ApplicationController
  layout 'sidebar_header_layouts'
  before_action :set_user, only: [:profile, :update_user_profile]

  respond_to :html

  def profile
    respond_with(@user)
  end

  def update_user_profile
    if @user.update(user_profile_params)
      flash[:success] = 'User information update success'
    else
      flash[:error] = 'User information update fail'
    end

    respond_with(@user)
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
