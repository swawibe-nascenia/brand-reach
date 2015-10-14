class ExploresController < ApplicationController
  before_filter :is_brand?, only: [:show]

  def show
    @influencers = User.influencers

    if params[:search_key].present?
      wildcard_search = "%#{params[:search_key]}%"
      @influencers = @influencers.where('industry LIKE :search OR country_name LIKE :search OR state_name LIKE :search', search: wildcard_search)
    elsif params[:advance_search].present?
      @influencers
    end
    # Rails.logger.info @influencers.inspect
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
