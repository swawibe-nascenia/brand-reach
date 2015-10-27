class FacebookController < ApplicationController
  def insights
    # if current_user.facebook.token_expires_at < Time.now
    #   # todo
    # end

    @accounts = current_user.facebook_accounts

    if @accounts.blank?
      flash[:error] = 'You must add at least one social account before you can view insights'
      return redirect_to profile_profile_index_path
    end

    @account = params[:id].present? ? @accounts.find(params[:id]) : @accounts.first
    @account.fetch_insights
  end
end
