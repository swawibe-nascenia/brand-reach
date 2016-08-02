class CampaignsController < ApplicationController
  before_action :current_user_campaign?, only: [:new_brand_payment]
  respond_to :html, :js, :csv

  protect_from_forgery :except => [:confirm_brand_payment]

  @@PRICE_PERCENT_CHANGE = 0.2

  def index
    if current_user.brand?
      brand_campaign
    else
      influencer_campaign
    end
  end

  def new
    @influencer = User.find(params[:receiver_id].to_i)

    if @influencer.active?
      @costs = User.find(params[:receiver_id].to_i).active_facebook_accounts.pluck(
          :status_update_cost, :profile_photo_cost, :cover_photo_cost,
          :video_post_cost, :photo_post_cost)

      @costs = @costs.map{ |x| x.map{|x| x+x*@@PRICE_PERCENT_CHANGE}} if @costs.present?
      @campaign = Campaign.new(sender_id: current_user.id,
                               receiver_id: params[:receiver_id], facebook_account_id: params[:social_account_id])
    else
      flash[:notice] = 'Your requested Influencer is not active now. Please chose others.'
      redirect_to explore_path
    end
  end

  def create
    @campaign = Campaign.new(campaign_params.except(:post_type,
                                                    :card_expiration_month, :card_expiration_year, :name, :schedule_type))
    @campaign.post_type = campaign_params[:post_type].to_i
    @campaign.card_expiration_month = campaign_params[:card_expiration_month].to_i
    @campaign.card_expiration_year = campaign_params[:card_expiration_year].to_i
    @campaign.name = campaign_params[:name].strip if  campaign_params[:name].present?
    @campaign.campaign_content = case campaign_params[:post_type].to_i
                                   when 0 then params[:status_message]
                                   when 1 then params[:profile_photo_url]
                                   when 2 then params[:cover_photo_url]
                                   when 3 then params[:video_url]
                                   when 4 then params[:post_photo_url]
                                 end
    @campaign.schedule_type = case campaign_params[:post_type].to_i
                                   when 0 then 'ongoing'
                                   when 1 then 'date_range'
                                   when 2 then 'date_range'
                                   when 3 then 'ongoing'
                                   when 4 then 'ongoing'
                              end
    # @campaign.name = @campaign.name.downcase if  campaign_params[:name].present?

    # unless @campaign.ongoing?
    temp_start_date = campaign_params[:start_date].to_date
    temp_start_time =  [1,2].include?(campaign_params[:post_type].to_i) ? params[:start_time].to_time : '12:00 am'.to_time

    if campaign_params[:end_date].present?
      temp_end_date = campaign_params[:end_date].to_date
      temp_end_time =  [1,2].include?(campaign_params[:post_type].to_i) ? params[:end_time].to_time : '11:59 pm'.to_time
    else
      temp_end_date = Time.now.to_time+10.days
      temp_end_time = '11:59 pm'.to_time+10.days
    end


    @campaign.start_date = DateTime.new(
        temp_start_date.year, temp_start_date.month, temp_start_date.day,
        temp_start_time.hour, temp_start_time.min
    )
    @campaign.end_date = DateTime.new(
        temp_end_date.year, temp_end_date.month, temp_end_date.day,
        temp_end_time.hour, temp_end_time.min
    )
    # end

    if @campaign.save
      @campaign.create_first_message
      CampaignMailer.new_campaign_notification(@campaign).deliver_now if @campaign.receiver.email_remainder_active?
      redirect_to offers_path
    else
      @influencer = User.find(params[:campaign][:receiver_id])
      @costs = User.find(params[:campaign][:receiver_id]).active_facebook_accounts.pluck(
          :status_update_cost, :profile_photo_cost, :cover_photo_cost,
          :video_post_cost, :photo_post_cost)
      @costs = @costs.map{ |x| x.map{|x| x+x*@@PRICE_PERCENT_CHANGE}} if @costs.present?
      render action: 'new'
    end
  end

  def campaign_status_change
    campaign = Campaign.find(params[:id])

    if params[:status] == 'true'
      campaign.status = Campaign.statuses[:engaged]
      CampaignMailer.notify_campaign_restart(campaign).deliver_now
    else
      campaign.status = Campaign.statuses[:paused]
      CampaignMailer.notify_campaign_pause(campaign).deliver_now
    end
    campaign.save

    respond_to do |format|
      format.json{ render json: {status: true} }
    end
  end

  def update_activity
    campaign = Campaign.find(params[:id])
    campaign.social_account_activity_id = params[:activity_id]
    campaign.fetch_insights

    redirect_to campaigns_path
  end

  def export
    if current_user.brand?
      export_brand_campaigns
    else
      export_influencer_campaigns
    end
  end

  def new_brand_payment
    @campaign = Campaign.find(params[:id].to_i)
  end

  def create_brand_payment
    @campaign = Campaign.find(params[:campaign][:id])
    @campaign.card_expiration_month = campaign_params[:card_expiration_month].to_i

    if @campaign.update(campaign_params.except(:card_expiration_month, :id))
      redirect_to campaigns_path
    else
      render action: 'new_brand_payment'
    end
  end

  def confirm_brand_payment
    crypto = CryptoService.new
    data_string = crypto.decrypt(params[:encResp], CONFIG[:ccavenue_working_key])
    data = Rack::Utils.parse_nested_query(data_string)

    Rails.logger.debug(data)
    @campaign = Campaign.find(data['order_id'])
    real_cost = (@campaign.cost * 0.83333333).ceil

    if @campaign.blank?
      flash[:error] = 'Invalid campaign ID'
      return redirect_to offers_path
    end

    if data['order_status'] == 'Success'
      if data['amount'].to_i == @campaign.cost.floor
        payment = BrandPayment.new
        payment.campaign = @campaign
        payment.billed_date = Date.today
        payment.amount_billed = real_cost
        payment.status = BrandPayment.statuses[:paid]
        payment.save

        @campaign.update_attributes({ status: Campaign.statuses[:engaged] })

        @campaign.receiver.update_column(:balance, @campaign.receiver.balance + real_cost)

        flash[:success] = 'Payment completed successfully'
        redirect_to payments_path
      else
        flash[:error] = 'Amount received from payment service does not match actual cost'
        redirect_to new_brand_payment_campaigns_path(@campaign.id)
      end
    else
      flash[:error] = "Payment not complete as: #{data['status_message']}. Please try again with valid information after 10-15 minutes."
      Rails.logger.info "............. if payment get error show params : #{params.inspect} ......................."
      redirect_to offers_path
    end
  end

  def campaign_image
  end

  def campaign_request_for_celebrities
    @sender = current_user
    @receiver = User.find(params[:receiver_id])
    @page = FacebookAccount.find(params[:social_account_id])

    begin
      CampaignMailer.mail_to_admin_for_campaign_request_to_celebrity(@sender, @receiver, @page).deliver_now
    rescue
      flash[:error] = 'Mail did not send to the Brandreach Successfully. Please try again to send request sometimes later'
      redirect_to explores_path
    end
    CelebrityCampaign.create(sender_id: @sender.id, receiver_id: @receiver.id, page_id: @page.id)
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, :text, :headline, :social_account_page_name,
                                     :receiver_id, :sender_id, :campaign_active, :cost,
                                     :facebook_account_id, :post_type, :number_of_likes,
                                     :number_of_post_reach, :number_of_comments, :id,
                                     :number_of_shares, :card_number, :card_expiration_year,
                                     :card_holder_name, :schedule_type, :card_expiration_month,
                                     :start_date, :end_date
    )
  end

  def influencer_campaign
    @campaigns = Campaign.engaged_campaigns_for(current_user)

    if @campaigns.blank?
      flash[:error] = 'You have no campaign'
      return redirect_to insights_facebook_index_path
    end

    render 'campaigns/influencer_campaign'
  end

  def brand_campaign
    @campaigns = Campaign.engaged_campaigns_from(current_user)
    @all_campaigns = Campaign.engaged_campaigns_from(current_user)

    if @campaigns.blank?
      flash[:error] = 'You have no campaign yet. Please View a profile to create one right away!'
      return redirect_to explores_path
    end

    @campaigns = @campaigns.where(id: params[:id]) if params[:id].present?
    @campaigns.each do |campaign|
      begin
        campaign.try(:fetch_insights)
      rescue Koala::Facebook::ClientError => ex
        campaign.facebook_error = true
        @campaign_error = true
      end
    end

    render 'campaigns/brand_campaign'
  end

  def export_influencer_campaigns
    if params[:campaign_ids].present?
      campaign_ids = params[:campaign_ids].split(',').uniq
      @campaigns = Campaign.engaged_campaigns_for(current_user).where(id: campaign_ids).order('id DESC')
    else
      @campaigns = Campaign.engaged_campaigns_for(current_user).order('id DESC')
    end

    @footer_text = "All Rights Reserved \u00AE Brand Reach | Copyright #{Time.now.year}"

    respond_to do |format|
      format.html{ render 'campaigns/export_influencer_campaigns'}
      format.pdf do
        headers['Content-Disposition'] = "filename=\"campaigns_list_influencer_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.pdf\""
        render 'campaigns/export_influencer_campaigns'
      end
      format.csv do
        #  Don't Try to Put Headers into single line, it wont work
        headers['Content-Disposition'] = "attachment; filename=\"campaigns_list_influencer_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.csv\""
        headers['Content-Type'] ||= 'text/csv'
        render 'campaigns/export_influencer_campaigns'
      end

      format.xls do
        headers['Content-Disposition'] = "attachment; filename=\"campaigns_list_influencer_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.xls\""
        render 'campaigns/export_influencer_campaigns'
      end
    end
  end

  def export_brand_campaigns

    if params[:campaign_ids].present?
      campaign_ids = params[:campaign_ids].split(',').uniq
      @campaigns = Campaign.engaged_campaigns_from(current_user).where(id: campaign_ids).order('id DESC')
    else
      @campaigns = Campaign.engaged_campaigns_from(current_user).order('id DESC')
    end

    @footer_text = "All Rights Reserved \u00AE Brand Reach | Copyright #{Time.now.year}"

    respond_to do |format|
      format.html{ render 'campaigns/export_brand_campaigns'}
      format.pdf do
        headers['Content-Disposition'] = "filename=\"campaigns_list_brand_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.pdf\""
        render 'campaigns/export_brand_campaigns'
      end
      format.csv do
        #  Don't Try to Put Headers into single line, it wont work
        headers['Content-Disposition'] = "attachment; filename=\"campaigns_list_brand_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.csv\""
        headers['Content-Type'] ||= 'text/csv'
        render 'campaigns/export_brand_campaigns'
      end

      format.xls do
        headers['Content-Disposition'] = "attachment; filename=\"campaigns_list_brand_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.xls\""
        render 'campaigns/export_brand_campaigns'
      end
    end
  end

  def current_user_campaign?
    if current_user.campaigns_sent.where(status: Campaign.statuses[:accepted], deleted_by_influencer: false, deleted_by_brand: false).pluck(:id).include?(params[:id].to_i)
      true
    else
      Rails.logger.info "Flash Message: ......... #{flash.inspect} .............."
      flash[:alert] = 'This Campaign is not Accessible'
      redirect_to offers_path
    end
  end
end
