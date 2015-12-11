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
    { head: 'Brand Invitation Successful', title: 'Brand Invitation Successful',
               message: 'Your Invitation successfully sent to Brand.'}
  end

  def influencer_invitation_success_message
    { head: 'Influencer Invitation Successful', title: 'Influencer Invitation Successful',
     message: 'Your Invitation successfully sent to Influencer.' }
  end

  def brand_active_success_message
    { head: 'Activate Brand Successful', title: 'Activate Brand Successful',
      message: 'Brand successfully activated.' }
  end

  def brand_suspend_success_message
    { head: 'Suspend Brand Successful', title: 'Suspend Brand Successful',
      message: 'Brand successfully suspended.' }
  end

end
