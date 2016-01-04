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
    page_info[:post_reach] = service.get_page_reach(data['id'])

    page_info
  end

  def get_post_info(post_id)
    post_info = {}
    data = @graph.get_object("#{post_id}?fields=likes,comments,shares")

    post_info[:number_of_likes] = data['likes'].present? ? data['likes']['data'].length : 0
    post_info[:number_of_comments] = data['comments'].present? ? data['comments']['data'].length : 0
    post_info[:number_of_shares] = data['shares'].present? ? data['shares']['count'] : 0

    post_info
  end

  def get_pages(id)
    pages = []
    @graph.get_object("#{id}/accounts").each do |d|
      service = InsightService.new(d['access_token'])

      pages << {
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

  def get_max_likes(id)
    pages = get_pages(id)
    pages.map{ |p| p[:followers] }.max || 0
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

  def get_page_reach(id)
    count = 0

    @graph.get_object("#{id}/insights/page_impressions/day").each do |d|
      count += d['values'].last['value']
    end

    count
  end

  def get_post_reach(post_id)
    count = 0

    @graph.get_object("#{post_id}/insights/post_impressions_unique").each do |d|
      count += d['values'].last['value']
    end

    count
  end

  def get_likes_by_country(id)
    get_aggregate_by_region(id, 'likes', 'country')
  end

  def get_reach_by_country(id)
    get_aggregate_by_region(id, 'impressions', 'country')
  end

  def get_likes_by_city(id)
    get_aggregate_by_region(id, 'likes', 'city')
  end

  def get_reach_by_city(id)
    get_aggregate_by_region(id, 'impressions', 'city')
  end

  def get_likes_by_gender(id, since)
    labels = {}
    datasets = {}

    @graph.get_object("#{id}/insights/page_fans_gender_age", { since: since }).each do |data|
      data['values'].each do |d|
        t = d['end_time'].to_date.strftime('%m.%y')
        labels[t] = true

        d['value'].each do |k, v|
          g, a = k.split('.')

          datasets[g] = {} if datasets[g].blank?
          datasets[g][t] = 0 if datasets[g][t].blank?
          datasets[g][t] += v
        end
      end
    end

    { labels: labels.keys, datasets: datasets }
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

  private

  def get_aggregate_by_region(id, metric, region)
    metric_name = metric == 'likes' ? "page_fans_#{region}" : "page_impressions_by_#{region}_unique"

    resp = {}

    @graph.get_object("#{id}/insights/#{metric_name}").each do |data|
      d = data['values'].last
      d['value'].each do |k, v|
        resp[k] = 0 if resp[k].blank?
        resp[k] += v
      end
    end

    resp
  end
end
