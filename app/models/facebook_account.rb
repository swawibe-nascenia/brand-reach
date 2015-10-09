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


  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------


  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

  def get_pages
    graph = InsightService.new(self.facebook.access_token)
    graph.get_pages(self.account_id)
  end

  def fetch_insights
    graph = InsightService.new(self.facebook.access_token)
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

  # ----------------------------------------------------------------------
  # == Class methods == #
  # ----------------------------------------------------------------------
end
