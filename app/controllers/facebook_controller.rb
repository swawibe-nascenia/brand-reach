class FacebookController < ApplicationController
  before_filter :is_influencer?, only: [:insights]

  def insights
    # if current_user.facebook.token_expires_at < Time.now
    #   # todo
    # end

    @accounts = current_user.active_facebook_accounts

    if @accounts.blank?
      flash[:error] = 'You must add at least one social account before you can view insights'
      return redirect_to profile_profile_index_path
    end

    @account = params[:id].present? ? @accounts.find(params[:id]) : @accounts.first

    if params[:refresh].present?
      @account.fetch_insights
    end
  end

  private

  def is_influencer?
    if current_user.influencer?
      return true
    else
      redirect_to explores_path
    end
  end
end
