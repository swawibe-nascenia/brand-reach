module ApplicationHelper
  def title(page_title)
    content_for :title, page_title.to_s
  end

  def bootstrap_class_for flash_type
    case flash_type
      when "success"
        "alert-success"
      when "error"
        "alert-error"
      when "alert"
        "alert-block"
      when "notice"
        "alert-info"
      else
        flash_type.to_s
    end
  end

  def current_path(path)
    "current" if current_page?(path)
  end

  def price_drop_down
    [
      ['5000 to 10000', '5000..10000'],
      ['10,000 to 50,000', '10000..50000'],
      ['50,000 to 1,00,000', '50000..100000'],
      ['1,00,000+', '1000000..100000000000000']
    ]
  end

  def followers_drop_down
    [
        ['1,000,000 to 5,000,000', '1000000..5000000'],
        ['5,000,001 to 10,000,000', '5000001..10000000'],
        ['10,000,000+', '1000000..1000000000000000']
    ]
  end

end
