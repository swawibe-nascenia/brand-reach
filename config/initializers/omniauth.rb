Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  # provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']

    provider :facebook, CONFIG[:fb_app_id], CONFIG[:fb_secret], scope: 'email,public_profile,manage_pages,read_insights,user_posts',
             info_fields: 'first_name,last_name, name, email, gender, location'
    # provider :facebook, '1410645245825135', 'a04206a380afd10288afefa381cf4114', scope: 'email,user_photos,public_profile,manage_pages,publish_actions,publish_pages,read_insights,read_mailbox,read_stream,rsvp_event'
end

# ads_management,ads_read,email,manage_notifications,manage_pages,publish_actions,publish_pages,read_custom_friendlists,read_insights,read_mailbox,read_page_mailboxes,read_stream,rsvp_event
