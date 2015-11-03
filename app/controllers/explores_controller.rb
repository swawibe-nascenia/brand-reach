class ExploresController < ApplicationController
  before_filter :is_brand?, only: [:show]

  def show
    @influencers = User.influencers.where(profile_complete: true)

    if params[:search_key].present?
      wildcard_search = "%#{params[:search_key]}%"
      @influencers = @influencers.where('industry LIKE :search OR country_name LIKE :search OR state_name LIKE :search', search: wildcard_search)
    elsif params[:advance_search].present?
      @influencers = @influencers.where(industry: params[:category]) if params[:category].present?
      @influencers = @influencers.where(country: params[:country]) if params[:country].present?
      #TODO @influencers = @influencers.where(fb_average_cost: [params['followers-range-value-lower']..params['followers-range-value-upper']])
      @influencers = @influencers.where(fb_average_cost: [params['influencer-price-value-lower']..params['influencer-price-value-upper']])
    end
    
    Rails.logger.info @influencers.inspect
    @influencers = @influencers.order(:name).page params[:page]
    @influencers
  end

  private

  def is_brand?
    if current_user.brand?
      return true
    else
      redirect_to profile_profile_index_path
    end
  end
end
