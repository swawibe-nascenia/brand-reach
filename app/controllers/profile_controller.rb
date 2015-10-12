class ProfileController < ApplicationController
  # layout 'sidebar_header_layouts'
  before_action :set_user, only: [:profile, :update, :update_accounts, :update_password]

  respond_to :html, :js

  def profile
    respond_with(@user)
  end

  def update
    if @user.update(user_params)
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
    render partial: 'shared/sub_region_select'
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

  def update_accounts
    graph = InsightService.new(params[:access_token])
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
    if @user.save
      flash[:success] = 'Accounts added successfully'
    else
      flash[:error] = 'Could not add account'
    end

    redirect_to profile_profile_index_path
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
                                 facebook_accounts_attributes: [:id, :status_update_cost, :profile_photo_cost, :cover_photo_cost, :video_post_cost]
    )
  end
end
