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
  has_and_belongs_to_many :categories

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :access_token, presence: true
  validates :name, :account_id, uniqueness: {message: 'Cannot proceed with the request as one of the pages you have selected is already on our portal'}
  validates :categories, presence: { message: '( Industry ) field is required' }, on: :update
  validates :status_update_cost, :profile_photo_cost, :cover_photo_cost,
            :video_post_cost, :photo_post_cost,
            :numericality => {:greater_than_or_equal_to => 0}, presence: true, on: :update

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
    #
    # self.number_of_posts = graph.get_number_of_posts(self.account_id)
    #
    if self.number_of_posts.present?
      self.number_of_posts = rand(self.number_of_posts..self.number_of_posts+10)
    else
      self.number_of_posts = rand(1000..5000)
    end

    self.post_reach = graph.get_post_reach(self.account_id)
    self.number_of_post_reach_of_post = graph.get_post_reach_of_post(self.account_id)
    self.profile_picture_url = graph.get_page_profile_picture(self.account_id)
    self.about = graph.get_page_about(self.account_id)
    self.category = graph.get_page_category(self.account_id)
    self.url = "https://www.facebook.com/#{self.account_id}"
    #
    # Only first time, facebook data will be called for 15 days, but in next update it will only fetch data for one day
    #
    if self.insights_updated_at.present?
      self.likes_by_country = graph.get_likes_by_country(self.account_id, 2.days.ago, self.likes_by_country)
      self.reach_by_country = graph.get_reach_by_country(self.account_id, 2.days.ago, self.reach_by_country)
      self.likes_by_city = graph.get_likes_by_city(self.account_id, 2.days.ago, self.likes_by_city)
      self.reach_by_city = graph.get_reach_by_city(self.account_id, 2.days.ago, self.reach_by_city)
      self.likes_by_gender_age_month = graph.get_likes_by_gender(self.account_id, 2.days.ago, self.likes_by_gender_age_month)
      self.likes_by_gender_age_week = graph.get_likes_by_gender(self.account_id, 2.days.ago, self.likes_by_gender_age_week)
    else
      self.likes_by_country = graph.get_likes_by_country(self.account_id, 15.days.ago, nil)
      self.reach_by_country = graph.get_reach_by_country(self.account_id, 15.days.ago, nil)
      self.likes_by_city = graph.get_likes_by_city(self.account_id, 15.days.ago, nil)
      self.reach_by_city = graph.get_reach_by_city(self.account_id, 15.days.ago, nil)
      self.likes_by_gender_age_month = graph.get_likes_by_gender(self.account_id, 12.month.ago, nil)
      self.likes_by_gender_age_week = graph.get_likes_by_gender(self.account_id, 1.week.ago, nil)
    end

    self.insights_updated_at = DateTime.now

    unless self.new_record?
      self.save(validate: false)
    end
  end

  def page_picture
    self.profile_picture_url.present? ? self.profile_picture_url : ActionController::Base.helpers.asset_path('facebook_default_page.png')
  end

  def country_data
    data = {}
    self.likes_by_country.each do |country_code, likes|
      country_name = ISO3166::Country[country_code].try(:name) if ISO3166::Country[country_code].present?
      if country_name.present?
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
    end
    self.reach_by_country.each do |country_code, reach|
      country_name = ISO3166::Country[country_code].try(:name) if ISO3166::Country[country_code].present?
      if country_name.present?
        if data[country_name].blank?
          data[country_name] = {
              country_code: country_code,
              country_lat: ISO3166::Country[country_code].latitude_dec,
              country_lon: ISO3166::Country[country_code].longitude_dec,
              likes: 0,
              reach: 0
          }
        end
        data[country_name][:reach] += reach
      end
    end
    data
  end

  def country_map_data
    country_data.map do |country_name, data|
      {
          title: country_name,
          description: "Likes: #{data[:likes]}<br/>Post reach: #{data[:reach]}",
          balloonText: '[[title]]<br/>[[description]]',
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
    Rails.logger.info "total amount is #{cost_array.inject(:+).inject(:+)} and field #{cost_array.inject(:+).length}"
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
      begin
        account.try(:fetch_insights)
      rescue
        Rails.logger.info "................. Could not able to update facebook page '#{account.name}'. Influencer need to update facebook authentication again from facebook app settings ........................."
        next
      end
    end
  end
end
