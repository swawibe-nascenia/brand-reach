class CampaignMailer < ApplicationMailer
  default from: 'hasanuzzaman@nascenia.com'

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

  def contact_us_mail(contact_us_params)
    @message = contact_us_params[:message]
    mail(to: 'swawibe@bdipo.com', subject: contact_us_params[:category])
  end

  def sing_up_notification_to_admin(user)
    @user = user
    Rails.logger.info "========================== Send User: #{user.inspect} sign up notification to admin.================"
    mail(from: 'hasanuzzaman@nascenia.com', to: 'hasanuzzaman@nascenia.com', subject: 'New user sign up to Bandreach')
  end

  def account_activate_notification_to_user(user, password)
    @user = user
    @password = password
    Rails.logger.info "========================== User: #{user.inspect} account has been successfully activated.================"
    mail(from: 'hasanuzzaman@nascenia.com', to: user.email, subject: 'Bandreach account activate')
  end

  def get_in_touch_mail(params)
    @full_name = params[:full_name]
    @email = params[:email]
    @phone_number = params[:phone_number]
    @message = params[:message]
    mail(from: 'hasanuzzaman@nascenia.com', to: 'swawibe@bdipo.com', subject: 'Get In Touch Message')
  end
end
