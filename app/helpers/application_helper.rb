module ApplicationHelper
  def title(page_title)
    content_for :title, page_title.to_s
  end

  def bootstrap_class_for flash_type
    case flash_type
    when 'success'
      'alert-success'
    when 'error'
      'alert-error'
    when 'alert'
      'alert-block'
    when 'notice'
      'alert-info'
    else
      flash_type.to_s
    end
  end

  def current_path(path)
    'active' if current_page?(path)
  end

  def price_drop_down
    [
        ['0 to 999', '0..999'],
        ['1000 to 4999', '1000..4999'],
        ['5000 to 9999', '5000..9999'],
        ['10,000+', '10000..461168601']
    ]
  end

  def followers_drop_down
    [
        ['1,00,000 to 5,00,000', '100000..500000'],
        ['5,00,001 to 1,000,000', '500001..1000000'],
        ['1,000,001 to 2,000,000', '1000001..2000000'],
        ['2,000,001 to 3,000,000', '2000001..3000000']
    ]
  end

  def post_type_drop_down
    [
      ['Status Update', 0],
      ['Profile Photo', 1],
      ['Cover Photo', 2],
      ['Video Post', 3],
      ['Photo Post', 4]
    ]
  end

  def brand_invitation_success_message
    {
        head: 'Brand invitation message status:',
        message: 'Brand invitation has been sent successfully.'
    }
  end

  def brand_re_invitation_success_message
    {
        head: 'Brand re-invitation message status:',
        message: 'Brand has been re-invited successfully.'
    }
  end

  def influencer_invitation_success_message
    {
        head: 'Influencer invitation message status:',
        message: 'Influencer invitation has been sent successfully.'
    }
  end

  def influencer_re_invitation_success_message
    {
        head: 'Influencer re-invitation message status:',
        message: 'Influencer has been re-invited successfully.'
    }
  end

  def brand_active_success_message
    {
        head: 'Activate Brand message status:',
        message: 'Brand has been activated successfully.'
    }
  end

  def brand_suspend_success_message
    {
        head: 'Suspend Brand message status:',
        message: 'Brand has been suspended successfully.'
    }
  end

  def admin_add_success_message
    {
        head: 'New admin add successful',
        message: 'New admin successfully added.'
    }
  end

  def password_reset_success_message
    {
        head: 'Password reset message status:',
        message: 'Password reset info successfully sent.'
    }
  end

  def user_delete_success_message
    {
        head: 'User delete status:',
        message: 'User delete is successful.'
    }
  end

  def campaign_delete_success_message
    {
        head: 'Campaign delete status:',
        message: 'Campaign delete is successful.'
    }
  end

  def user_delete_fail_message
    {
        head: 'User delete status:',
        message: 'User delete is fail.'
    }
  end

  def payment_paid_success
    {
        head: 'Influencer payment paid status:',
        message: 'Payment has been successfully completed.'
    }
  end

  def influencer_bank_account_delete_success
    {
        head: 'Bank account delete status:',
        message: 'Bank Account has been successfully deleted.'
    }
  end

  def local_time_convert(time)
    if time.to_date == Date.today
      local_time(time, '%I:%M %P')
    else
      local_time(time, '%d-%m-%Y')
    end
  end

  def local_time_long_format(time)
    local_time(time, '%d-%m-%Y %I:%M:%S %P')
  end

  def home_path
    if current_user && current_user.brand?
      brand_home_public_index_path
    elsif current_user && current_user.influencer?
      influencer_home_public_index_path
    else
      root_path
    end
  end

  def offer_receiver_id(offer)
    current_user.id == offer.sender_id ? offer.receiver_id : offer.sender_id
  end

  def image_validation(account)
    img_url = account.page_picture
    res = Net::HTTP.get_response(URI.parse(img_url))
    img_url = ActionController::Base.helpers.asset_path('facebook_default_page.png') unless res.code == '200'
    img_url
  end
end
