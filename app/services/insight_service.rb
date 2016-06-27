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
    # page_info[:number_of_posts] = service.get_number_of_posts(data['id'])
    page_info[:number_of_posts] = rand(1000..5000)
    page_info[:post_reach] = service.get_page_reach(data['id'])

    page_info
  end

  def get_post_info(post_id)
    post_info = {}
    data = @graph.get_object("#{post_id}?fields=likes.summary(true),comments.summary(true),shares")

    post_info[:number_of_likes] = data['likes'].present? ? data['likes']['summary']['total_count'] : 0
    post_info[:number_of_comments] = data['comments'].present? ? data['comments']['summary']['total_count'] : 0
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
    @graph.get_object("#{id}/insights/page_views_total/week", {:until => Time.now.beginning_of_day().to_i}).each do |d|
      count += d['values'].last['value'] if d['values'].last['value']
    end
    count
  end

  def get_number_of_posts(id)
    count = 0
    self.paginate(@graph.get_object("#{id}/posts", {:limit => 100})) do |data|
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

    @graph.get_object("#{post_id}/insights/page_posts_impressions_unique/week", {:until => Time.now.beginning_of_day().to_i}).each do |d|
      count += d['values'].last['value']
    end

    count
  end

  def get_post_reach_of_post(post_id)
    count = 0

    @graph.get_object("#{post_id}/insights/post_impressions_unique").each do |d|
      count += d['values'].last['value']
    end

    count
  end

  def get_likes_by_country(id, since, previous_data)
    get_aggregate_by_region(id, 'likes', 'country', since, previous_data)
  end

  def get_reach_by_country(id, since, previous_data)
    get_aggregate_by_region(id, 'impressions', 'country', since, previous_data)
  end

  def get_likes_by_city(id, since, previous_data)
    get_aggregate_by_region(id, 'likes', 'city', since, previous_data)
  end

  def get_reach_by_city(id, since, previous_data)
    get_aggregate_by_region(id, 'impressions', 'city', since, previous_data)
  end

  def get_total_action_button_clicks(id, since)
    labels = {}
    datasets = {}

    @graph.get_object("#{id}/insights/page_cta_clicks_logged_in_total/day", {since: since, :until => Time.now.beginning_of_day().to_i}).each do |data|
      data['values'].each do |d|
        t = d['end_time'].to_date.prev_day.strftime('%B %d')
        labels[t] = true

        g = 'M'
        datasets[g] = {} if datasets[g].blank?
        datasets[g][t] = 0 if datasets[g][t].blank?

        d['value'].each do |k, v|
          datasets[g] = {} if datasets[g].blank?
          datasets[g][t] = 0 if datasets[g][t].blank?
          datasets[g][t] = v
        end
      end
    end
      { labels: labels.keys, datasets: datasets }
      #count += d['values'].last['value'].values if d['values'].last['value'].values
      #count
  end

  def get_total_people_action_button_clicks(id, since)
    labels = {}
    datasets = {}

    @graph.get_object("#{id}/insights/page_cta_clicks_logged_in_unique/day", {since: since, :until => Time.now.beginning_of_day().to_i}).each do |data|
      data['values'].each do |d|
        t = d['end_time'].to_date.prev_day.strftime('%B %d')
        labels[t] = true

        g = 'M'
        datasets[g] = {} if datasets[g].blank?
        datasets[g][t] = 0 if datasets[g][t].blank?

        d['value'].each do |k, v|
          datasets[g] = {} if datasets[g].blank?
          datasets[g][t] = 0 if datasets[g][t].blank?
          datasets[g][t] = v
        end
      end
    end
    { labels: labels.keys, datasets: datasets }
  end

  def get_actions_by_gender_age_week(id)
    labels = {}
    datasets = {}
    age_group = {}

    @graph.get_object("#{id}/insights/page_cta_clicks_by_age_gender_logged_in_unique/week", { :until => Time.now.beginning_of_day().to_i }).each do |data|
      data['values'].each do |d|
        t = d['end_time'].to_date.strftime('%B %d')
        labels[t] = true

        ['M', 'F', 'U'].each do |g|
          datasets[g] = {} if datasets[g].blank?
          datasets[g][t] = 0 if datasets[g][t].blank?
        end

        d['value'].each do |key, value|
          value.each do |key1, value1|
            age = key1
            value1.each do |key2, value2|
              age_group[key2] = {} if age_group[key2].blank?
              age_group[key2][age] = 0 if age_group[key2][age].blank?
              age_group[key2][age] = value2
            end
          end
        end

        age_group = age_group.map{|k,v| [k,v.sort.to_h]}.to_h
      end
    end

    { labels: labels.keys, datasets: datasets, age_group: age_group }
  end

  def get_actions_by_device_week(id)
    labels = {}
    datasets = {}
    user_group = {}

    @graph.get_object("#{id}/insights/page_cta_clicks_by_site_logged_in_unique/week", { :until => Time.now.beginning_of_day().to_i }).each do |data|
      data['values'].each do |d|
        t = d['end_time'].to_date.prev_day.strftime('%B %d')
        labels[t] = true

        ['WWW', 'MOBILE'].each do |g|
          datasets[g] = {} if datasets[g].blank?
          datasets[g][t] = 0 if datasets[g][t].blank?
        end

        d['value'].each do |key, value|
          value.each do |key1, value1|
            user_group[key1] = {} if user_group[key1].blank?
            user_group[key1][t] = 0 if user_group[key1][t].blank?
            user_group[key1][t] = value1
          end
        end

        user_group = user_group.map{|k,v| [k,v.sort.to_h]}.to_h
      end
    end

    { labels: labels.keys, datasets: datasets, user_group: user_group }
  end

  def get_likes_by_gender(id, since, previous_data)
    if previous_data.nil?
      labels = {}
      datasets = {}
    else
      labels = previous_data[:labels]
      labels = Hash[ *labels.collect { |v| [ v, true ] }.flatten ]
      datasets = previous_data[:datasets]
    end
    age_group = {}

    @graph.get_object("#{id}/insights/page_fans_gender_age", { since: since }).each do |data|
      data['values'].each do |d|
        t = d['end_time'].to_date.strftime('%m.%y')
        labels[t] = true

        ['M', 'F'].each do |g|
          datasets[g] = {} if datasets[g].blank?
          datasets[g][t] = 0 if datasets[g][t].blank?
        end

        d['value'].each do |k, v|
          g, a = k.split('.')

          datasets[g] = {} if datasets[g].blank?
          datasets[g][t] = 0 if datasets[g][t].blank?
          datasets[g][t] = [v, datasets[g][t]].max
        end

        d['value'].each do |k, v|
          g, a = k.split('.')

          age_group[g] = {} if age_group[g].blank?
          age_group[g][a] = 0 if age_group[g][a].blank?
          age_group[g][a] = [v, age_group[g][a]].max
        end
        age_group = age_group.map{|k,v| [k,v.sort.to_h]}.to_h
      end
    end

    { labels: labels.keys, datasets: datasets, age_group: age_group }
  end

  def get_page_profile_picture(account_id)
    resp = @graph.get_object("#{account_id}/picture", { width: 200, redirect: false })
    resp['data']['url']
  end

  def get_page_about(account_id)
    resp = @graph.get_object("#{account_id}?fields=about")
    resp['about']
  end

  def get_page_category(account_id)
    resp = @graph.get_object("#{account_id}?fields=category")
    resp['category']
  end

  def paginate(resp)
    loop do
      begin
        break if resp.nil? || resp.count == 0
        yield resp
        resp = resp.next_page
      rescue => error
        Rails.logger.info "Get Error in Paginate block when doing resp.next_page #{error.inspect}"
      end
    end
  end

  private

  def get_aggregate_by_region(id, metric, region, since, previous_data)
    metric_name = metric == 'likes' ? "page_fans_#{region}" : "page_impressions_by_#{region}_unique"

    if previous_data.nil?
      resp = {}
    else
      resp = previous_data
    end

    @graph.get_object("#{id}/insights/#{metric_name}", { since: since }).each do |data|
      data['values'].each do |d|
        d['value'].each do |k, v|
          resp[k] = 0 if resp[k].blank?
          resp[k] = [v, resp[k]].max
        end
      end
    end

    resp
  end
end
