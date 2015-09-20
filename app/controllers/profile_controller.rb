class ProfileController < ApplicationController
  # layout 'sidebar_header_layouts'
  before_action :set_user, only: [:profile, :update, :update_password]

  respond_to :html, :js

  def profile
    respond_with(@user)
  end

  def update
    if @user.update(user_profile_params)
      flash[:success] = 'User information update success'
    else
      flash[:error] = 'User information update fail'
    end

    redirect_to profile_profile_index_path
  end

  def update_password
    if @user.update_with_password(user_profile_params)
      sign_in @user, :bypass => true
      flash[:success] = 'User Password update success'
    else
      flash[:error] = 'Old Password was Not correct or Retype Password does Not match with New Password'
    end

    redirect_to profile_profile_index_path
  end

  def subregion_options
    render partial: 'sub_region_select'
  end

  def add_social_site(provider)

  end

  def edit_profile_picture
    Rails.logger.info '------------ with in image update method--------'
    Rails.logger.info params
    current_user.image = params[:user][:image]
    if current_user.save
      @success = true
     else
      @success = false
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_profile_params
    params.require(:user).permit(:first_name, :last_name, :email, :company_name, :company_email, :image,
                                 :industry, :phone, :street_address, :landmark, :city, :state,
                                 :country, :zip_code, :short_bio, :password, :password_confirmation, :current_password
    )
  end
end
