class PublicController < ApplicationController
	layout 'public'
  # before_action  :set_service, except: [:index]
  skip_before_filter :authenticate_user!, :block_admin_user ,:check_profile_completion ,:check_profile_social_accounts
  before_filter :set_statistics, only: [:home, :brand_home]

  respond_to :html

  # nfluencers public home page
  def home
  end

  # Brands public home page
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
    CampaignMailer.get_in_touch_mail(params).deliver_now
    flash[:success] = 'Your message is sent'
    redirect_to influencer_home_public_index_path
  end

  def faqs
  end

  def terms
  end

  def sign_up_requirements
  end

protected

  def set_statistics
    @influencer_number = User.active_influencers.count
    @total_follower_number = FacebookAccount.all.pluck(:number_of_followers).sum
    @total_post_reach = FacebookAccount.all.pluck(:post_reach).sum
  end

	def set_service
		# @service = InsightService.new current_user
	end
end
