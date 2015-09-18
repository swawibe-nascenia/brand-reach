class PublicController < ApplicationController
	layout 'public'
  # before_action  :set_service, except: [:index]
  skip_before_filter :authenticate_user!

  respond_to :html

  # use this for go to influencer public home page
  def home

  end

  def brand_home

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

  def get_in_touch
    redirect_to home_public_index_path
  end

protected
	def set_service
		# @service = InsightService.new current_user
	end
end
