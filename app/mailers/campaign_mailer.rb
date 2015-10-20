class CampaignMailer < ApplicationMailer
  default from: 'dev.brandreach.com'

  def new_campaign_notification(campaign)
    @campaign = campaign
    @receiver = @campaign.receiver
    Rails.logger.info "==========================New campaign request send to #{@receiver.full_name}================"
    mail(to: @receiver.email, subject: 'New campaign request')
  end

  def campaign_accept_notification(campaign)
    @campaign = campaign
    @receiver = @campaign.sender
    Rails.logger.info "========================== Campaign  Accepted notification send to #{@receiver.full_name}================"
    mail(to: @receiver.email, subject: 'Campaign has been accepted')
  end

  def campaign_deny_notification(campaign)
    @campaign = campaign
    @receiver = @campaign.sender
    Rails.logger.info "==========================Campaign Deny notification send to #{@receiver.full_name}================"
    mail(to: @receiver.email, subject: 'Campaign has been denied')
  end

  def campaign_deny_undo_notification(campaign)
    @campaign = campaign
    @receiver = @campaign.sender
    Rails.logger.info "==========================Campaign Deny Undo notification send to #{@receiver.full_name}================"
    mail(to: @receiver.email, subject: 'Campaign deny has been undo')
  end

  def campaign_new_message_notification(message)
    @message = message
    @receiver = @message.receiver
    Rails.logger.info "========================== Campaign new message notification send to #{@receiver.full_name}================"
    mail(to: @receiver.email, subject: 'New message to campaign')
  end

  def campaign_start_notification(campaign)
    @campaign = campaign
    @receiver = @campaign.receiver
    Rails.logger.info "========================== Campaign start notification send to #{@receiver.full_name}================"
    mail(to: @receiver.email, subject: 'New message to campaign')
  end
end
