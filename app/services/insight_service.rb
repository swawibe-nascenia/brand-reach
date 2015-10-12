class InsightService < BaseService
  Koala.config.api_version = 'v2.4'

  def initialize(access_token)
    @graph = Koala::Facebook::API.new(access_token)
  end

  def get_profile_picture
    resp = @graph.get_object('/me/picture', { width: 200, redirect: false })
    resp['data']['url']
  end

  def get_page_info(id)
    page_info = {}
    data = @graph.get_object("#{id}?fields=name,access_token")
    page_info[:name] = data['name']
    page_info[:access_token] = data['access_token']

    service = InsightService.new(data['access_token'])

    page_info[:number_of_followers] = service.get_number_of_likes(data['id'])
    page_info[:daily_page_views] = service.get_daily_page_views(data['id'])
    page_info[:number_of_posts] = service.get_number_of_posts(data['id'])
    page_info[:post_reach] = service.get_post_reach(data['id'])

    page_info
  end

  def get_pages(id)
    pages = []
    @graph.get_object("#{id}/accounts").each do |d|
      service = InsightService.new(d['access_token'])

      pages += {
          id: d['id'],
          name: d['name'],
          followers: service.get_number_of_likes(d['id']),
      }
    end
    pages
  end

  def get_number_of_likes(id)
    data = @graph.get_object("#{id}?fields=likes")
    data['likes']
  end

  def get_number_of_followers(id)
    count = 0

    @graph.get_object("#{id}/insights/page_follower_adds_unique/day").each do |d|
      count += d['values'].last['value']
    end

    @graph.get_object("#{id}/insights/page_follower_removes_unique/day").each do |d|
      count -= d['values'].last['value']
    end

    count
  end

  def get_daily_page_views(id)
    count = 0
    @graph.get_object("#{id}/insights/page_views/day").each do |d|
      count += d['values'].last['value']
    end
    count
  end

  def get_number_of_posts(id)
    count = 0
    self.paginate(@graph.get_object("#{id}/posts")) do |data|
      count += data.count
    end
    count
  end

  def get_post_reach(id)
    count = 0

    @graph.get_object("#{id}/insights/page_impressions/day").each do |d|
      count += d['values'].last['value']
    end

    count
  end

  def paginate(resp)
    loop do
      break if resp.count == 0
      yield resp
      resp = resp.next_page
    end
  end

  def get_info(page_id = 'VoHoaiLinh')
    response = nil
    begin
      Rails.logger.info @graph.access_token
      response = @graph.get_object(page_id)
      name = page_id
      if response["about"] && response["about"].length > 0
        name = response["about"].to_s[0..100]
      end
      Page.create({
                      username: page_id,
                      name: name
                  })
    rescue Exception => e
      Rails.logger.error("!!!!ERROR: #{e.inspect}")
      @is_error = true
    end
    response
  end

  def get_posts(page_id = 'VoHoaiLinh')
    response = nil
    begin
      Rails.logger.info @graph.access_token
      response = @graph.get_object("#{page_id}/posts")
    rescue Exception => e
      Rails.logger.error("!!!!ERROR: #{e.inspect}")
      @is_error = true
    end
    response
  end

  def get_insights(page_id = 'VoHoaiLinh')
    response = nil
    begin
      @pages = @graph.get_object('me/accounts')
      token = @current_user.access_token
      Rails.logger.error("user------------------------------------------------")
      Rails.logger.error(token)
      params = {pretty: 0, since: 1.months.ago.to_i, suppress_http_code: 1, until: Time.now.to_i}
      @pages.each do |pg|
        Rails.logger.error("pageid==page_id: #{pg['id'] || pg['name']} === #{page_id}")
        if pg['id']==page_id.downcase || pg['name'].to_s.downcase == page_id.downcase
          token = pg['access_token']
        end
      end
      Rails.logger.error("page------------------------------------------------")
      Rails.logger.error(token)
      grapher = Koala::Facebook::API.new token
      response = grapher.get_object("#{page_id}/insights", params)
    rescue Exception => e
      Rails.logger.error("!!!!ERROR: #{e.inspect}")
      @is_error = true
    end
    response
  end
end
