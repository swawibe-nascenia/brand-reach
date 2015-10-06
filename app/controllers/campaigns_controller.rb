class CampaignsController < ApplicationController

  respond_to :html, :js

  def influencer_campaign
    @campaigns = Campaign.all
    # @campaigns = Campaign.where(offer_id: current_user.offers_received_ids) || []
  end

  def brand_campaign

  end

  def new
    @influencer = current_user
    @campaign = Campaign.new(offer_id: params[:offer_id])
  end

  def create
    @campaign = Campaign.new(campaign_params.except(:post_type, :card_expiration_month, :card_expiration_year))
    @campaign.post_type = campaign_params[:post_type].to_i
    @campaign.card_expiration_month = campaign_params[:card_expiration_month].to_i
    @campaign.card_expiration_year = campaign_params[:card_expiration_year].to_i
    if @campaign.daily?
      @campaign.start_date = Time.now.strftime('%d/%m/%Y')
    end

    if @campaign.save
      redirect_to brand_campaign_campaigns_path
    else
      @influencer = current_user
      render 'new'
    end

  end

  def campaign_status_change
    campaign = Campaign.find(params[:id])
    campaign.campaign_active = params[:campaign_active]
    campaign.save
    nil

  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, :text, :headline, :social_account_page_name, :start_date,
                                     :end_date, :campaign_active, :cost, :social_account_activity_id,
                                     :post_type, :number_of_likes, :number_of_post_reach, :number_of_comments,
                                     :number_of_shares, :card_number, :card_expiration_month, :card_expiration_year, :card_holder_name, :offer_id, :schedule_type
    )
  end

end
