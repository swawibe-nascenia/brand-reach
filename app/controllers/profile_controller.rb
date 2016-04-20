class ProfileController < ApplicationController
  skip_before_action :check_profile_completion
  skip_before_action :check_profile_social_accounts, only: [:select_accounts, :update_accounts]
  skip_before_filter :authenticate_user!, only: [:verify_brand_profile]
  before_action :set_user, only: [:profile, :update, :update_accounts, :update_password, :toggle_available, :deactivate_account, :show_settings, :update_profile_settings, :contact_us_save]

  respond_to :html, :js

  def show_user
    @user = User.find params[:id]
  end

  def profile
    @all_industries = Category.all.order(:name)
    @selected_industries = @user.categories
    respond_with(@user)
  end

  def update
    # @industries = Category.all.order(:name).pluck(:name)
    @all_industries = Category.all.order(:name)
    @selected_industries = @user.categories

    # refactor user info update method
    if password_change_request?
      #   user want to change password
      if password_change_info_correct?
        save_industries
        save_account_category
        if @user.update(user_params.except(:industry, :current_password, :password_confirmation, facebook_accounts_attributes: [:category]))
          flash[:success] = 'User Information has been updated successfully.' if flash[:error].nil?
          sign_in @user, bypass: true
          redirect_to profile_profile_index_path
        else
          render 'profile'
        end
      else
        flash[:error] = 'Current Password was not correct.'
        redirect_to profile_profile_index_path
      end
    else
      save_industries
      save_account_category
      if @user.update(user_params.except(:current_password, :password, :password_confirmation, :industry, facebook_accounts_attributes: [:category]))
        flash[:success] = 'User Information has been updated successfully.' if flash[:error].nil?
        redirect_to profile_profile_index_path
      else
        render 'profile'
      end
    end
    # end of refactor
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
    current_user.crop_x = params[:crop_x]
    current_user.crop_y = params[:crop_y]
    current_user.crop_w = params[:crop_w]
    current_user.crop_h = params[:crop_h]

    current_user.image = params[:user][:image]

    if current_user.save
      @success = true
    else
      @success = false
    end
  end

  def crop_profile_picture
    current_user.crop_x = params[:crop_x]
    current_user.crop_y = params[:crop_y]
    current_user.crop_w = params[:crop_w]
    current_user.crop_h = params[:crop_h]

    current_user.image.recreate_versions!(:thumb, :medium, :explore_image)
  end

  def select_accounts
  end

  def update_accounts
    # now we use user access token instead temp generated token
    # TODO we need to think how we can handle facebook authentication problem
    graph = InsightService.new(current_user.access_token)
    @errors = []
    logger.info "------------------------------------parameter from browser are #{params[:accounts].inspect}"
    # TODO need to change accept to active
    active_account_ids = @user.campaigns_received.where(status: Campaign.statuses[:accepted]).pluck(:facebook_account_id)

    @user.active_facebook_accounts.where.not(id: active_account_ids, account_id: params[:accounts]).update_all(is_active: false)

    if params[:accounts].present?
      params[:accounts].each do |account_id|
        logger.info "------------------------------------with in account update with  #{account_id}"
        page_info = graph.get_page_info(account_id)

        account = @user.facebook_accounts.where(account_id: account_id).first
        if account.blank?
          logger.info "account blank with provided id"
          account = @user.facebook_accounts.build
        end

        account.assign_attributes({
                                      is_active: true,
                                      name: page_info[:name],
                                      account_id: account_id,
                                      access_token: page_info[:access_token],
                                      token_expires_at: params[:expires_in].to_i.seconds.from_now,

                                      number_of_followers: page_info[:number_of_followers],
                                      daily_page_views: page_info[:daily_page_views],
                                      number_of_posts: page_info[:number_of_posts],
                                      post_reach: page_info[:post_reach],
                                  })

        if account.id.blank?
          logger.info "new account with name #{account.name} and error #{account.errors.messages}"
          account.fetch_insights
          @errors << "Cannot proceed with the request as the page  #{account.name} you have selected is already on our portal"  unless account.save || account.persisted?
        else
          logger.info "Update existing account with id and account_id are #{account.id} and #{account.account_id}"
          account.save(validate: false)
        end
      end
    end

    udpate_user_profile(@user)

    if @user.in_limbo? # new user
      if @user.active_facebook_accounts.count > 0
        @user.active_facebook_accounts.each do |account|
          account.fetch_insights
        end

        @user.update_column(:status, User.statuses[:active])
        redirect_to profile_profile_index_path
      else
        # show form with error
      end
    end

  end

  def contact_us
    @contact_us = ContactUs.new
  end

  def contact_us_save
    @contact_us = ContactUs.new(contact_us_params)
    @contact_us.user_id = current_user.id

    if @contact_us.save
      CampaignMailer.contact_us_mail(contact_us_params, current_user).deliver_now
      flash[:success] = 'Message sent successfully'
      redirect_to contact_us_profile_index_path
    else
      render 'contact_us'
    end
  end

  def update_profile_settings
    if @user.update(user_params)
      flash[:success] = 'User information has been updated Successfully'
    else
      flash[:error] = 'User information update fail'
    end

    redirect_to settings_profile_index_path
  end

  def toggle_available
    if params[:available]
      @user.update_column(:is_available, true)
    else
      @user.update_column(:is_available, false)
    end
  end

  def deactivate_account
    if @user.engaged_campaigns.present?
      flash[:error] = 'You have a running/engaged campaigns. So you can not deactivate now.'
      redirect_to settings_profile_index_path
    else
      @user.status = User.statuses[:inactive]

      if @user.save(validate: false)
        flash[:success] = 'Account Deactivated successfully'
        redirect_to destroy_user_session_path
      else
        flash[:error] = 'Account deactivation failed'
        redirect_to settings_profile_index_path
      end
    end
  end

  def faqs
  end

  def verify_brand_profile
    token = params[:token]
    user = User.find(params[:id])
    @success = true

    if user && user.channel_name == token && user.invited?
      password = Devise.friendly_token.first(8)
      user.password = password
      user.password_confirmation = password
      user.status = User.statuses[:active]
      user.save(validate: false)
      CampaignMailer.account_activate_notification_to_user(user, password).deliver_now
    else
      @success = false
    end

    redirect_to root_path
  end

  def change_profile_image
  end
  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :company_name,
                                 :company_email, :image, :email_remainder_active, :sms_remainder_active,
                                 :phone, :street_address, :landmark, :city, :state, :is_available,
                                 :country, :zip_code, :short_bio, :password, :password_confirmation,
                                 :current_password, :status,:crop_x, :crop_y, :crop_w, :crop_h,
                                 facebook_accounts_attributes: [:id, :status_update_cost, :profile_photo_cost,
                                                                :cover_photo_cost, :video_post_cost, :photo_post_cost, category: []],
                                 industry: []
    )
  end

  def contact_us_params
    params.require(:contact_us).permit(:category, :message)
  end

  def udpate_user_profile(user)
    if user.profile_complete? && user.active_facebook_accounts.count > 0
      user.update_profile_complete(true)
    else
      user.update_profile_complete(false)
    end
  end

  def password_change_request?
    user_params[:current_password].present? && user_params[:password].present? && user_params[:password_confirmation].present?
  end

  def password_change_info_correct?
    logger.info "User password need to changed #{user_params.except(:facebook).inspect }"
    match_confirm = user_params[:password] ==  user_params[:password_confirmation]

    if @user.valid_password?(user_params[:current_password]) && match_confirm
      # @user.password = user_params[:password]
      # sign_in @user, bypass: true
      # flash[:success] = 'User Password update success'
      true
    else
      flash[:error] = 'Old Password was Not correct or Retype Password does Not match with New Password'
      false
    end
  end

  def save_industries
    if user_params[:industry].present?
      ids = user_params[:industry][1..-1]
      @user.category_ids = ids
      @user.save
    end
  end

  def save_account_category
    if params[:user][:facebook_accounts_attributes].present?
      params[:user][:facebook_accounts_attributes].each do |key, value|
        facebook_account = FacebookAccount.find value[:id]
        ids = value[:category][1..-1]
        facebook_account.category_ids = ids
        facebook_account.save
      end
    end
  end
end
