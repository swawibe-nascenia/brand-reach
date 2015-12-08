class Admin::AdminsController < ApplicationController
  skip_before_action :check_profile_completion, :block_admin_user
  skip_before_action :authenticate_user!, only: [:log_in]
  before_filter :log_in_user?, only: [:log_in]
  # before_filter :admin?
  respond_to :html, :js, :json

  layout 'admin'

  def manage_admins
    authorize :admin, :manage_admins?
    @admins = User.where(user_type: User.user_types[:admin])
  end

  def create
    authorize :admin, :manage_admins?

    @admin = User.new(admin_params) do |user|
      user.is_active = true,
      user.verified = true,
      user.user_type = User.user_types[:admin]
    end

    @success = true
    @messages = ''

    if @admin.save
      @messages << 'New admin added successfully.'
    else
      @messages = @admin.errors.full_messages
      @success = false
    end

    Rails.logger.info "----------------Admin is -----------------------#{@admin}------------------"
    respond_to do |format|
      format.js{ }
    end
  end

  def update
    authorize :admin, :manage_brandreach?
    @admin = current_user
    if @admin.update(admin_params.except(:current_password, :password, :password_confirmation))
      if admin_params[:current_password].present? && admin_params[:password].present?
        if @admin.update_with_password(admin_params)
          sign_in  @admin, :bypass => true
          flash[:success] = 'User Password update success'
        else
          flash[:error] = 'Old Password was Not correct or Retype Password does Not match with New Password'
        end
      end
      flash[:success] = 'User Information has been updated successfully' if flash[:error].nil?
      redirect_to profile_admin_admins_path
    else
      render 'profile'
    end
  end

  def destroy
    authorize :admin, :manage_admins?

    @admin = User.where(id: params[:id], user_type: User.user_types[:admin]).first
    @error_message = ''
    @success = false

    if @admin
      @success = true
      @admin.destroy
      @messages = 'Successfully admin deleted.'
    else
      @error_message = 'Requested operation fail.'
    end
  end

  def brands_request
    authorize :admin, :manage_brandreach?
    @brands = User.where(user_type: User.user_types[:brand], verified: false)
  end

  def profile
    authorize :admin, :manage_brandreach?
    @admin = current_user
  end

  def log_in
    render :layout => false
  end

  def influencer_list
    authorize :admin, :manage_brandreach?
    @influencers = User.influencers
  end

  def brand_list
    authorize :admin, :manage_brandreach?
    @brands = User.brands
  end

  def deactivate_user
    authorize :admin, :manage_brandreach?

    @user = User.where(id: params[:id], verified: true,
                       user_type: [User.user_types[:influencer],
                       User.user_types[:brand]
                       ]).first

    @success = false
    @message = 'User deactivate request fail'

    if @user
      @user.update_column(:verified, false)
      @success = true
      @message = 'Successfully deactivate user.'
    end
  end

  def activate_user
    authorize :admin, :manage_brandreach?

    @user = User.where(id: params[:id], verified: false,
                       user_type: [User.user_types[:influencer],
                                   User.user_types[:brand]
                       ]).first

    @success = false
    @message = 'User deactivate request fail'

    if @user
      @user.update_column(:verified, true)
      @success = true
      @message = 'Successfully deactivate user.'
    end
  end
  private

  def admin_params
    params.require(:user).permit(:current_password, :first_name, :last_name, :email, :password, :password_confirmation,
                    :is_active, :verified, :user_type)
  end

  def log_in_user?
    if user_signed_in?
      redirect_to after_sign_in_path_for(current_user)
    end
  end
end
