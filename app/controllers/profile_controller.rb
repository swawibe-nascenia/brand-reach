class ProfileController < ApplicationController
  # layout 'sidebar_header_layouts'
  before_action :set_user, only: [:profile, :update, :update_password]

  respond_to :html, :js

  def profile
    @facebook = @user.facebook || Facebook.new
    respond_with(@user)
  end

  def update
    if @user.update(user_params.except(:facebook))
      if @user.facebook.present? & user_params[:facebook].present?
        facebook = @user.facebook
        facebook.update(user_params[:facebook])
        facebook.save
      else

      end
      flash[:success] = 'User information update success'
    else
      flash[:error] = 'User information update fail'
    end

    redirect_to profile_profile_index_path
  end

  def update_password
    if @user.update_with_password(user_params.except(:facebook))
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

  def connect_facebook

  end

  def show_settings

  end

  def edit_profile_picture
    current_user.image = params[:user][:image]
    if current_user.save
      @success = true
    else
      @success = false
    end
  end


  def contact_us

  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :company_name, :company_email, :image,
                                 :industry, :phone, :street_address, :landmark, :city, :state,
                                 :country, :zip_code, :short_bio, :password, :password_confirmation, :current_password,
                                 facebook: [:status_update_price, :profile_photo_price, :banner_photo_price, :video_post_price]
    )
  end
end
