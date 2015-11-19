class ExploresController < ApplicationController
  before_filter :is_brand?, only: [:show]

  #  Range.new(*'1..10'.split('..').map(&:to_i))
  def show
    @influencers = User.influencers.where(profile_complete: true)

    if params[:search_key].present?
      wildcard_search = "%#{params[:search_key]}%"
      @influencers = @influencers.where('industry LIKE :search OR country_name LIKE :search OR state_name LIKE :search', search: wildcard_search)
    end
    @influencers = @influencers.where(industry: params[:category]) if params[:category].present?
    @influencers = @influencers.where(country: params[:country]) if params[:country].present?
    if params[:price].present?
      price_range = Range.new(*params[:price].split('..').map(&:to_i))
      @influencers = @influencers.where(fb_average_cost: price_range)
    end
    if params[:followers].present?
      price_range = Range.new(*params[:followers].split('..').map(&:to_i))
      @influencers = @influencers.where(fb_average_cost: price_range)
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
