class InsightService < BaseService
	Koala.config.api_version = "v2.3"
	attr :is_error, :error_message

	def initialize(arg)
		super(arg)
		@is_error = false
		@graph = Koala::Facebook::API.new @current_user.access_token
	end

	def get_info page_id="VoHoaiLinh"
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

	def get_posts page_id="VoHoaiLinh"
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

	def get_insights page_id="VoHoaiLinh"
		response = nil
		begin
			params = {pretty: 0, since: 1.months.ago.to_i, suppress_http_code: 1, until: Time.now.to_i}
			Rails.logger.info @graph.access_token
			response = @graph.get_object("#{page_id}/insights", params)
		rescue Exception => e
			Rails.logger.error("!!!!ERROR: #{e.inspect}")
			@is_error = true
		end
		response
	end



end
