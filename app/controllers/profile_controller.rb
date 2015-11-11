class ProfileController < ApplicationController
  skip_before_action :check_profile_completion
  skip_before_filter :authenticate_user!, only: [:verify_brand_profile]
  before_action :set_user, only: [:profile, :update, :update_accounts, :update_password, :toggle_available, :deactivate_account, :show_settings, :update_profile_settings, :contact_us_save]

  respond_to :html, :js

  def profile
    respond_with(@user)
  end

  def update
    if @user.update(user_params.except(:current_password, :password, :password_confirmation))
      if user_params[:current_password].present? && user_params[:password].present?
        if @user.update_with_password(user_params.except(:facebook))
          sign_in @user, :bypass => true
          flash[:success] = 'User Password update success'
        else
          flash[:error] = 'Old Password was Not correct or Retype Password does Not match with New Password'
        end
      end
      flash[:success] = 'User Information update success' if flash[:error].nil?
      redirect_to profile_profile_index_path
    else
      render 'profile'
    end
  end

  def update_password
    # if @user.update_with_password(user_params.except(:facebook))
    #   sign_in @user, :bypass => true
    #   flash[:success] = 'User Password update success'
    # else
    #   flash[:error] = 'Old Password was Not correct or Retype Password does Not match with New Password'
    # end
    #
    # redirect_to profile_profile_index_path
  end

  def subregion_options
    render partial: 'shared/sub_region_select'
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

  def update_accounts
    graph = InsightService.new(params[:access_token])

    @user.facebook_accounts.update_attributes(is_active: false)

    params[:accounts].each do |account_id|
      page_info = graph.get_page_info(account_id)
      account = @user.facebook_accounts.where(account_id: account_id).first
      if account.blank?
        account = @user.facebook_accounts.build
      end

      account.assign_attributes({
                                    name: page_info[:name],
                                    account_id: account_id,
                                    access_token: page_info[:access_token],
                                    token_expires_at: params[:expires_in].to_i.seconds.from_now,

                                    number_of_followers: page_info[:number_of_followers],
                                    daily_page_views: page_info[:daily_page_views],
                                    number_of_posts: page_info[:number_of_posts],
                                    post_reach: page_info[:post_reach],
                                })
    end
    if @user.save(validate: false)
      flash[:success] = 'Accounts added successfully'
    else
      flash[:error] = 'Could not add account'
    end

    redirect_to profile_profile_index_path
  end

  def contact_us
    @contact_us = ContactUs.new
  end

  def contact_us_save
    @contact_us = ContactUs.new(contact_us_params.except(:category))
    @contact_us.category = params[:contact_us][:category].to_i
    @contact_us.user_id = current_user.id

    if @contact_us.save
      CampaignMailer.contact_us_mail(@contact_us).deliver_now
      flash[:success] = 'Message Sent Successfully'
      redirect_to contact_us_profile_index_path
    else
      render 'contact_us'
    end
  end

  def update_profile_settings
    if @user.update(user_params)
      flash[:success] = 'User information update success'
    else
      flash[:error] = 'User information update fail'
    end

    redirect_to show_settings_profile_index_path
  end

  def toggle_available
    if params[:available]
      @user.update_column(:is_available, true)
    else
      @user.update_column(:is_available, false)
    end
  end

  def deactivate_account
    @user.is_active = false
    if @user.save
      redirect_to destroy_user_session_path
      flash[:success] = 'Account Deactivated successfully'
    else
      flash[:error] = 'Account could not Deactivated'
    end
  end

  def faqs
  end

  def verify_brand_profile
    token = params[:token]
    user = User.find(params[:id])
    @success = true

    if user && user.channel_name == token
      password = Devise.friendly_token.first(8)
      user.password = password
      user.password_confirmation = password
      user.verified = true
      user.save
      CampaignMailer.account_activate_notification_to_user(user, password).deliver_now
      render :layout => false
    else
      @success = false
      render :layout => false
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :company_name,
      :company_email, :image, :email_remainder_active, :sms_remainder_active,
      :industry, :phone, :street_address, :landmark, :city, :state, :is_available,
      :country, :zip_code, :short_bio, :password, :password_confirmation,
      :current_password, :is_active,
      facebook_accounts_attributes: [:id, :status_update_cost, :profile_photo_cost, :cover_photo_cost, :video_post_cost]
    )
  end

  def contact_us_params
    params.require(:contact_us).permit(:category, :message)
  end
end
