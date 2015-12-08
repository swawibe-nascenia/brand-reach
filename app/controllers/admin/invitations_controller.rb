class Admin::InvitationsController < ApplicationController
  skip_before_action :check_profile_completion
  layout 'admin'

  def index
    @invitations = Admin::Invitation.all
  end

  def create
    @invitation = Admin::Invitation.create(invitation_params)
  end

  def destroy
  end

  private

  def invitation_params
    params.require(:invitation).permit(:name, :email)
  end
end
