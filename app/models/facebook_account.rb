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


  # ----------------------------------------------------------------------
  # == File Uploader == #
  # ----------------------------------------------------------------------


  # ----------------------------------------------------------------------
  # == Associations and Nested Attributes == #
  # ----------------------------------------------------------------------

  belongs_to :influencer, class_name: 'User'

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :access_token, presence: true

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  after_save :update_influencer_fb_average_cost


  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------


  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def fetch_insights
    graph = InsightService.new(self.influencer.access_token)
    pages = []

    self.number_of_followers = graph.get_number_of_followers(self.account_id)
    self.daily_page_views = graph.get_daily_page_views(self.account_id)
    self.number_of_posts = graph.get_number_of_posts(self.account_id)
    self.post_reach = graph.get_post_reach(self.account_id)

    Rails.logger.info([self.number_of_followers, self.daily_page_views, self.number_of_posts, self.post_reach])

    # graph.get_object("#{self.account_id}/insights")['data'].each do |page|
    #   pages << page['name']
    # end

    pages
  end


  private

  def update_influencer_fb_average_cost
    cost_array = influencer.facebook_accounts.pluck(:status_update_cost, :profile_photo_cost, :cover_photo_cost, :video_post_cost)
    Rails.logger.info "===================== array #{cost_array.inject(:+)} "
    avg_cost = cost_array.inject(:+).inject(:+) / (cost_array.inject(:+).length)
    Rails.logger.info "total amoutn is #{cost_array.inject(:+).inject(:+)} and field #{cost_array.inject(:+).length}"
    influencer.update_column(:fb_average_cost, avg_cost)
  end
  # ----------------------------------------------------------------------
  # == Class methods == #
  # ----------------------------------------------------------------------
end
