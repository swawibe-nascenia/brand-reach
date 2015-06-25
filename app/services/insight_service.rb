class InsightService < BaseService
	Koala.config.api_version = "v2.3"
	def initialize(arg)
		super(arg)
		@graph = Koala::Facebook::API.new @current_user.access_token
	end
	def get_posts page_id="VoHoaiLinh"
		@graph.get_object("#{page_id}/posts")
	end

	def get_insights page_id="VoHoaiLinh"
		params = {pretty: 0, since: 1.months.ago.to_i, suppress_http_code: 1, until: Time.now.to_i}
		@graph.get_object("#{page_id}/insights")
	end
	
end