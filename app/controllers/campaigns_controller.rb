class CampaignsController < ApplicationController

  respond_to :html, :js, :csv

  def influencer_campaign
    @campaigns = current_user.campaigns_received
  end

  def brand_campaign
    @campaigns = current_user.campaigns_sent
  end

  def new
    @influencer = User.find(params[:receiver_id].to_i)
    @costs = User.find(params[:receiver_id].to_i).facebook_accounts.pluck(:status_update_cost, :profile_photo_cost, :cover_photo_cost, :video_post_cost)
    @campaign = Campaign.new(sender_id: current_user.id, receiver_id: params[:receiver_id])

  end

  def create
    @campaign = Campaign.new(campaign_params.except(:post_type, :card_expiration_month, :card_expiration_year))
    @campaign.post_type = campaign_params[:post_type].to_i
    @campaign.card_expiration_month = campaign_params[:card_expiration_month].to_i
    @campaign.card_expiration_year = campaign_params[:card_expiration_year].to_i

    unless @campaign.date_range?
      @campaign.start_date = Time.now.strftime('%d/%m/%Y')
    end

    if @campaign.save
      @campaign.create_first_method
      redirect_to brand_campaign_campaigns_path
    else
      @influencer =  User.find(params[:campaign][:receiver_id])
      @costs = User.find(params[:campaign][:receiver_id]).facebook_accounts.pluck(:status_update_cost, :profile_photo_cost, :cover_photo_cost, :video_post_cost)
      render :action => 'new'
    end

  end

  def campaign_status_change
    campaign = Campaign.find(params[:id])
    campaign.campaign_active = params[:campaign_active]
    campaign.save
    nil

  end

  def export_campaigns
    campaign_ids = params[:campaign_ids].uniq
    @campaigns = Campaign.where(id: campaign_ids)

    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"campaign_list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end

  end

  def new_brand_payment
    # @campaign = Campaign.find(params[:id])
    @campaign = Campaign.last
  end

  def create_brand_payment
    @campaign = Campaign.find(params[:campaign][:id])

    if @campaign.update(campaign_params)
      redirect_to brand_campaign_campaigns_path
    else
      render :action => 'new_brand_payment'
    end

  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, :text, :headline, :social_account_page_name, :start_date, :receiver_id, :sender_id,
                                     :end_date, :campaign_active, :cost, :social_account_activity_id,
                                     :post_type, :number_of_likes, :number_of_post_reach, :number_of_comments,
                                     :number_of_shares, :card_number, :card_expiration_month, :card_expiration_year, :card_holder_name, :schedule_type
    )
  end

end
