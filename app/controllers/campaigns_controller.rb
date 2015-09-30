class CampaignsController < ApplicationController

  respond_to :html, :js

  def influencer_campaign

  end

  def brand_campaign
    redirect_to influencer_campaign_campaigns_path
  end

end
