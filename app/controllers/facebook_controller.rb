class FacebookController < ApplicationController
  def insights
    # if current_user.facebook.token_expires_at < Time.now
    #   # todo
    # end

    @accounts = current_user.facebook_accounts
    @accounts.each do |account|
      account.fetch_insights
    end
  end
end
