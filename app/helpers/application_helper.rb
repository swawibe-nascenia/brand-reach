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
        ['5000 to 10000', '5000..10000'],
        ['10,000 to 50,000', '10000..50000'],
        ['50,000 to 1,00,000', '50000..100000'],
        ['1,00,000+', '1000000..461168601']
    ]
  end

  def followers_drop_down
    [
        ['10 to 1000', '10..1000'],
        ['1,000,000 to 5,000,000', '1000000..5000000'],
        ['5,000,001 to 10,000,000', '5000001..10000000'],
        ['10,000,000+', '10000001..461168601']
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

  def user_delete_fail_message
    {
        head: 'User delete status:',
        message: 'User delete is fail.'
    }
  end

  def payment_paid_success
    {
        head: 'Influencer payment paid status:',
        message: 'Payment has been paid successfully.'
    }
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
end
