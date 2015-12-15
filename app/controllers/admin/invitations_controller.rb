class Admin::InvitationsController < ApplicationController
  skip_before_action :check_profile_completion, :block_admin_user
  layout 'admin'

  # show influencer invitation list
  def index
    authorize :admin, :manage_brandreach?
    @invitations = Admin::Invitation.all

    if params[:email].present?
      wildcard_search = "%#{params[:email].strip! || params[:email]}%"
      @invitations = @invitations.where('email LIKE :search' , search: wildcard_search)
    end

    @invitations = @invitations.page params[:page]
  end

  def create
    authorize :admin, :manage_brandreach?
    @invitation = Admin::Invitation.create(invitation_params)
  end

  def brand_invitation
    authorize :admin, :manage_brandreach?
    @invited_brands= User.where(status: User.statuses[:invited], user_type: User.user_types[:brand])

    if params[:email].present?
      wildcard_search = "%#{params[:email].strip! || params[:email]}%"
      @invited_brands = @invited_brands.where('email LIKE :search' , search: wildcard_search)
    end

    @invited_brands = @invited_brands.page params[:page]
  end

  def create_brand_invitation
    authorize :admin, :manage_brandreach?

    @user = User.new(user_params)
    password = Devise.friendly_token.first(8)
    @user.password = password
    @user.password_confirmation = password
    @user.user_type = User.user_types[:brand]
    @user.status = User.statuses[:invited]

    @success = true
    @messages = []

    unless @user.save
      @messages = @user.errors.full_messages
      @success = false
    end

    respond_to do |format|
      format.js{ }
    end
  end

  def brand_resend
    user = User.where(id: params[:id], status: User.statuses[:invited]).first
    @success = false

    if user
      CampaignMailer.brand_invitation(user).deliver_now
      @success = true
    else
      @messages = 'Something was wrong.'
    end
  end

  def influencer_resend
    influencer_invitation = Admin::Invitation.find params[:id]
    @success = false

    if influencer_invitation
      CampaignMailer.influencer_invitation(influencer_invitation).deliver_now
      @success = true
    else
      @messages = 'Something was wrong.'
    end
  end

  def destroy
  end

  private

  def invitation_params
    params.require(:invitation).permit(:first_name, :last_name, :email)
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :position, :company_name, :phone, :short_bio)
  end
end
