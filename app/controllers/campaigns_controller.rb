class CampaignsController < ApplicationController

  respond_to :html, :js

  def influencer_campaign
      @campaigns = Campaign.where(offer_id: current_user.offers_received_ids) || []
  end

  def brand_campaign

  end

  def new
    @influencer = current_user
  end

  def create
    @campaign = Campaign.new(campaign_params.except(:campaign_post_type, :card_expiration_month, params[:date][:card_expiration_year]))
    @campaign.campaign_post_type = campaign_params[:campaign_post_type].to_i
    @campaign.card_expiration_month = campaign_params[:card_expiration_month].to_i
    @campaign.card_expiration_year = params[:date][:card_expiration_year].to_i
    @campaign.save
  end

  private

  def campaign_params
    params.require(:campaign).permit(:campaign_name, :campaign_text, :campaign_headline, :social_account_page_name, :campaign_start_date,
                                 :campaign_end_date, :campaign_active, :campaign_cost, :social_account_activity_id,
                                 :campaign_post_type, :number_of_likes, :number_of_post_reach, :number_of_comments,
                                 :number_of_shares, :card_number, :card_expiration_month, :card_expiration_year, :card_holder_name, :offer_id, :schedule_type
    )
  end

end
