class HomeController < ApplicationController
	# layout 'landing'
	before_action :authenticate_user!, :set_service, except: [:index]

  def index
  	if current_user
  		redirect_to :dashboard
  	end
  end

  def dashboard
  	if !current_user
  		redirect_to root_path
  	end
  end

  def search
  	if !current_user
  		redirect_to root_path
  	end
  	@resp = @service.get_info(params[:query])

  end

  def get_posts
  	@resp = @service.get_posts(params[:query])
  end

  def get_insights
		@post_insight = params[:insight] == 'post'
  	@resp = @service.get_insights(params[:query])
  end

protected
	def set_service
		@service = InsightService.new current_user
	end
end
