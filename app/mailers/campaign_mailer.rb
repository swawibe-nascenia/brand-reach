class CampaignMailer < ApplicationMailer
  default from: 'mc@thebrandreach.com'

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
    mail(to: 'superadmin@thebrandreach.com', subject: contact_us_params[:category])
  end

  def sing_up_notification_to_admin(user)
    @user = user
    Rails.logger.info "========================== Send User: #{user.inspect} sign up notification to admin.================"
    mail(from: 'mc@thebrandreach.com', to: 'mc@thebrandreach.com', subject: 'New user sign up to Bandreach')
  end

  def account_activate_notification_to_user(user, password)
    @user = user
    @password = password
    Rails.logger.info "========================== User: #{user.inspect} account has been successfully activated.================"
    mail(from: 'mc@thebrandreach.com', to: user.email, subject: 'Bandreach account activate')
  end

  def get_in_touch_mail(params)
    @full_name = params[:full_name]
    @email = params[:email]
    @phone_number = params[:phone_number]
    @message = params[:message]
    mail(from: 'mc@thebrandreach.com', to: 'superadmin@thebrandreach.com', subject: 'Get In Touch Message')
  end

  def influencer_invitation (influencer_invitation)
    @name = influencer_invitation.full_name
    @mail = influencer_invitation.email

    @brandReach = root_url(sign_up_modal: true)
    subject = "We'd like to have you on Brandreach.
               Be a influencer on one of the most amazing knowledge sharing platforms."
    mail(from: 'mc@thebrandreach.com', to: @mail, subject: subject)
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
    mail(from: 'mc@thebrandreach.com', to: @mail, subject: subject)
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
    mail(to: @receiver.email, subject: 'Campaign pause notification')
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
    mail(to: @receiver.email, subject: 'Campaign restart notification')
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
    mail(to: @receiver.email, subject: 'Campaign stop notification')
  end
end
