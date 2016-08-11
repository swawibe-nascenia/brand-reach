class CampaignMailer < ApplicationMailer
  default from: 'stb@thebrandreach.com'
  @@mc_email = 'coo@thebrandreach.com'
  @@stb_email = 'stb@thebrandreach.com'
  @@super_admin_email = 'hello@thebrandreach.com'

  def new_campaign_notification(campaign)
    @campaign = campaign
    @receiver = @campaign.receiver
    Rails.logger.info "==========================New campaign request send to #{@receiver.full_name}================"
    mail(to: "#{@receiver.email}, #{@@mc_email}" , subject: 'New campaign request')
  end

  def campaign_accept_notification(campaign)
    @campaign = campaign
    @sender = @campaign.sender
    Rails.logger.info "========================== Campaign  Accepted notification send to #{@sender.full_name}================"
    mail(to: "#{@sender.email}, #{@@mc_email}", subject: 'Campaign has been accepted')
  end

  def campaign_deny_notification(campaign)
    @campaign = campaign
    @sender = @campaign.sender
    Rails.logger.info "==========================Campaign Deny notification send to #{@sender.full_name}================"
    mail(to: "#{@sender.email}, #{@@mc_email}", subject: 'Campaign has been denied')
  end

  def campaign_deny_undo_notification(campaign)
    @campaign = campaign
    @sender = @campaign.sender
    Rails.logger.info "==========================Campaign Deny Undo notification send to #{@sender.full_name}================"
    mail(to: "#{@sender.email}, #{@@mc_email}", subject: 'Campaign deny has been undo')
  end

  def campaign_new_message_notification(message)
    @message = message
    @receiver = @message.receiver
    Rails.logger.info "========================== Campaign new message notification send to #{@receiver.full_name}================"
    mail(to: "#{@receiver.email}, #{@@mc_email}", subject: 'New message to campaign')
  end

  def campaign_start_notification(campaign)
    @campaign = campaign
    @receiver = @campaign.receiver
    Rails.logger.info "========================== Campaign start notification send to #{@receiver.full_name}================"
    mail(to: "#{@receiver.email}, #{@@mc_email}", subject: 'New message to campaign')
  end

  def contact_us_mail(contact_us_params, user)
    @message = contact_us_params[:message]
    @user = user
    mail(to: @@super_admin_email, subject: contact_us_params[:category])
  end

  def sing_up_notification_to_admin(user)
    @user = user
    Rails.logger.info "========================== Send User: #{user.inspect} sign up notification to admin.================"
    mail(from: @@stb_email, to: 'mc@thebrandreach.com', subject: 'New user sign up to Brandreach')
  end

  def account_activate_notification_to_user(user, password)
    @user = user
    @password = password
    Rails.logger.info "========================== User: #{user.inspect} account has been successfully activated.================"
    mail(from: @@stb_email, to: user.email, subject: 'Brandreach account activate')
  end

  def account_activate_after_deactivate_notification_to_user(user)
    @user = user
    mail(from: @@stb_email, to: user.email, subject: 'Brandreach account activate')
  end

  def get_in_touch_mail(params)
    @full_name = params[:full_name]
    @email = params[:email]
    @phone_number = params[:phone_number]
    @message = params[:message]
    mail(from: @@stb_email, to: 'superadmin@thebrandreach.com', subject: 'Get In Touch Message')
  end

  def influencer_invitation (influencer_invitation)
    @name = influencer_invitation.full_name
    @mail = influencer_invitation.email

    @brandReach = root_url(sign_up_modal: true)
    subject = "We'd like to have you on Brandreach.
               Be a influencer on one of the most amazing knowledge sharing platforms."
    mail(from: @@stb_email, to: @mail, subject: subject)
  end

  def brand_invitation (brand, row_token)
    @row_token = row_token
    @user = brand
    @name = brand.full_name
    @mail = brand.email
    Rails.logger.info "=============== Send brand invitaions to request name #{@name} email#{@mail}=====#{brand.inspect}==========="

    # @brandReach = root_url
    subject = "We'd like to have you on Brandreach.
               Be a brand on one of the most amazing knowledge sharing platforms."
    mail(from: @@stb_email, to: @mail, subject: subject)
  end

  def notify_campaign_pause(campaign)
    @campaign = campaign
    @receiver = @campaign.receiver
    @brand = @campaign.sender
    @message = case @campaign.post_type
                 when 'status_update' then 'You can now remove your status message.'
                 when 'profile_photo' then 'You can now remove your profile photo.'
                 when 'cover_photo' then 'You can now remove your cover photo.'
                 when 'video_post' then 'You can now remove your video post.'
                 when 'photo_post' then 'You can now remove your photo post.'
               end
    Rails.logger.info "==========================Campaign pause send to #{@receiver.full_name}================"
    mail(to: "#{@receiver.email}, #{@@mc_email}", subject: 'Campaign pause notification')
  end

  def notify_campaign_restart(campaign)
    @campaign = campaign
    @receiver = @campaign.receiver
    @brand = @campaign.sender
    @message = case @campaign.post_type
               when 'status_update' then 'Please update your status with campaign status message.'
               when 'profile_photo' then 'Please update your profile photo with campaign  image.'
               when 'cover_photo' then 'Please update your cover photo with campaign image.'
               when 'video_post' then 'Please post campaign video.'
               when 'photo_post' then 'Please post campaign photo.'
               end
    Rails.logger.info "==========================Campaign restart send to #{@receiver.full_name}================"
    mail(to: "#{@receiver.email}, #{@@mc_email}", subject: 'Campaign restart notification')
  end

  def notify_campaign_stop(campaign)
    @campaign = campaign
    @receiver = @campaign.receiver
    @brand = @campaign.sender
    @message = case @campaign.post_type
               when 'status_update' then 'You can now remove your status message.'
               when 'profile_photo' then 'You can now remove your profile photo.'
               when 'cover_photo' then 'You can now remove your cover photo.'
               when 'video_post' then 'You can now remove your video post.'
               when 'photo_post' then 'You can now remove your photo post.'
               end
    Rails.logger.info "==========================Campaign stop send to #{@receiver.full_name}================"
    mail(to: "#{@receiver.email}, #{@@mc_email}", subject: 'Campaign stop notification')
  end

  def mail_to_admin_for_campaign_request_to_celebrity(sender, receiver, page)
    @sender = sender
    @receiver = receiver
    @page = page
    Rails.logger.info "========================== New campaign request for celebrity: #{@receiver.full_name} , sender name: #{@sender.full_name} , page name: #{@page.name} ================"
    mail(to: "#{@@mc_email}", from: @@stb_email, subject: "New campaign request from Brand: #{@sender.full_name} to Influencer: #{@receiver.full_name} for Page name: #{@page.name}")
  end
end
