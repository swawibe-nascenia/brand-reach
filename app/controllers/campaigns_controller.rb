class CampaignsController < ApplicationController

  respond_to :html, :js, :csv

  def influencer_campaign
    @campaigns = Campaign.active_campaigns_for(current_user)
  end

  def brand_campaign
    @campaigns = Campaign.active_campaigns_from(current_user)

    if @campaigns.blank?
      flash[:error] = 'You have no campaign'
      return redirect_to profile_profile_index_path
    end

    @campaign = params[:id].present? ? @campaigns.find_by_id(params[:id]) : @campaigns.last
    @campaign.fetch_insights
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
      @campaign.create_first_message
      CampaignMailer.new_campaign_notification(@campaign).deliver_now if @campaign.receiver.email_remainder_active?
      redirect_to brand_campaign_campaigns_path(id: @campaign.id)
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

  def update_activity
    campaign = Campaign.find(params[:id])
    campaign.social_account_activity_id = params[:activity_id]
    campaign.save

    redirect_to influencer_campaign_campaigns_path
  end

  def export_influencer_campaigns
    if params[:campaign_ids].present?
      campaign_ids = params[:campaign_ids].split(',').uniq
      @campaigns = Campaign.where(id: campaign_ids)
    else
      @campaigns = current_user.campaigns_received
    end

    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"campaigns_list_influencer.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def export_brand_campaigns
    if params[:campaign_id].present?
      @campaigns = Campaign.where(id: params[:campaign_id])
    else
      @campaigns = current_user.campaigns_sent
    end

    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"campaigns_list_brand.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def new_brand_payment
    @campaign = Campaign.find(params[:format])
    # @campaign = Campaign.last
  end

  def create_brand_payment
    @campaign = Campaign.find(params[:campaign][:id])
    @campaign.card_expiration_month = campaign_params[:card_expiration_month].to_i

    if  @campaign.update(campaign_params.except(:card_expiration_month))
      redirect_to brand_campaign_campaigns_path
    else
      render :action => 'new_brand_payment'
    end

  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, :text, :headline, :social_account_page_name, :start_date, :receiver_id, :sender_id,
                                     :end_date, :campaign_active, :cost, :facebook_account_id,
                                     :post_type, :number_of_likes, :number_of_post_reach, :number_of_comments,
                                     :number_of_shares, :card_number, :card_expiration_month, :card_expiration_year, :card_holder_name, :schedule_type
    )
  end

end
