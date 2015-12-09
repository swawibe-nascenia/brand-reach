class Admin::InvitationsController < ApplicationController
  skip_before_action :check_profile_completion, :block_admin_user
  layout 'admin'

  def index
    authorize :admin, :manage_brandreach?
    @invitations = Admin::Invitation.all.page params[:page]
  end

  def create
    authorize :admin, :manage_brandreach?
    @invitation = Admin::Invitation.create(invitation_params)
  end

  def destroy
  end

  private

  def invitation_params
    params.require(:invitation).permit(:first_name, :last_name, :email)
  end
end
