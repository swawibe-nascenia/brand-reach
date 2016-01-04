class FacebookAccount < ActiveRecord::Base
  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------

  serialize :likes_by_country
  serialize :reach_by_country
  serialize :likes_by_city
  serialize :reach_by_city
  serialize :likes_by_gender_age_month
  serialize :likes_by_gender_age_week

  # ----------------------------------------------------------------------
  # == File Uploader == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Associations and Nested Attributes == #
  # ----------------------------------------------------------------------

  belongs_to :influencer, class_name: 'User'
  has_many :campaigns

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :access_token, presence: true
  validates :status_update_cost, :profile_photo_cost, :cover_photo_cost,
            :video_post_cost, :photo_post_cost,
            :numericality => {:greater_than_or_equal_to => 0}, presence: true

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  after_save :update_influencer_fb_average_cost, :update_influencer_fb_max_followers

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def fetch_insights
    graph = InsightService.new(self.influencer.access_token)

    self.number_of_followers = graph.get_number_of_likes(self.account_id)
    self.daily_page_views = graph.get_daily_page_views(self.account_id)
    self.number_of_posts = graph.get_number_of_posts(self.account_id)
    self.post_reach = graph.get_post_reach(self.account_id)

    self.likes_by_country = graph.get_likes_by_country(self.account_id)
    self.reach_by_country = graph.get_reach_by_country(self.account_id)
    self.likes_by_city = graph.get_likes_by_city(self.account_id)
    self.reach_by_city = graph.get_reach_by_city(self.account_id)
    self.likes_by_gender_age_month = graph.get_likes_by_gender(self.account_id, 12.month.ago)
    self.likes_by_gender_age_week = graph.get_likes_by_gender(self.account_id, 1.week.ago)

    self.insights_updated_at = DateTime.now

    self.save(validate: false)
  end

  def country_data
    data = {}
    self.likes_by_country.each do |country_code, likes|
      country_name = ISO3166::Country[country_code].name
      if data[country_name].blank?
        data[country_name] = {
            country_code: country_code,
            country_lat: ISO3166::Country[country_code].latitude_dec,
            country_lon: ISO3166::Country[country_code].longitude_dec,
            likes: 0,
            reach: 0
        }
      end
      data[country_name][:likes] += likes
    end
    self.reach_by_country.each do |country_code, reach|
      country_name = ISO3166::Country[country_code].name
      data[country_name] = { country_code: country_code, likes: 0, reach: 0 } if data[country_name].blank?
      data[country_name][:reach] += reach
    end
    data
  end

  def country_map_data
    country_data.map do |country_name, data|
      {
          title: country_name,
          latitude: data[:country_lat],
          longitude: data[:country_lon],
          height: 20,
          width: 20,
      }
    end
  end

  def city_data
    data = {}
    self.likes_by_city.each do |city_name, likes|
      data[city_name] = { likes: 0, reach: 0 } if data[city_name].blank?
      data[city_name][:likes] += likes
    end
    self.reach_by_city.each do |city_name, reach|
      data[city_name] = { likes: 0, reach: 0 } if data[city_name].blank?
      data[city_name][:reach] += reach
    end
    data
  end

  def gender_line_chart_data
    colors = ['#9BE6F1', '#EA358C', '#ff4400']
    color_index = 0
    {
        labels: self.likes_by_gender_age_month[:labels],
        datasets: self.likes_by_gender_age_month[:datasets].map do |gender, data|
          color = colors[color_index]
          color_index += 1

          {
              label: gender,
              fillColor: color,
              strokeColor: color,
              pointColor: color,
              pointStrokeColor: color,
              pointHighlightFill: color,
              pointHighlightStroke: color,
              data: data.values.map { |value| value/1000.0 }
          }
        end,
    }
  end

  def has_engaged_capmaign?
    campaigns.where(status: Campaign.statuses[:engaged]).count
  end

  private

  def update_influencer_fb_average_cost
    cost_array = influencer.active_facebook_accounts.pluck(:status_update_cost, :profile_photo_cost, :cover_photo_cost, :video_post_cost)
    Rails.logger.info "===================== array #{cost_array.inject(:+)} "
    avg_cost = cost_array.inject(:+).inject(:+) / (cost_array.inject(:+).length)
    Rails.logger.info "total amoutn is #{cost_array.inject(:+).inject(:+)} and field #{cost_array.inject(:+).length}"
    influencer.update_column(:fb_average_cost, avg_cost)
  rescue Exception
    return
  end

  def update_influencer_fb_max_followers
    max_followers_number = influencer.calculate_max_followers
    influencer.update_column(:max_followers, max_followers_number)
  rescue Exception
    return
  end

  # ----------------------------------------------------------------------
  # == Class methods == #
  # ----------------------------------------------------------------------

  def self.fetch_all_insights
    FacebookAccount.where(is_active: true).each do |account|
      account.fetch_insights
    end
  end
end
