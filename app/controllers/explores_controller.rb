class ExploresController < ApplicationController
  before_filter :is_brand?, only: [:show]

  def show
    authorize :brand, :brand?
    @influencers = User.active_influencers.where(profile_complete: true)

    if params[:search_key].present?
      wildcard_search = "%#{params[:search_key].strip! || params[:search_key]}%"
      @influencers = @influencers.includes(:categories).where('categories.name LIKE :search OR
                                                  first_name LIKE :search OR
                                                  last_name LIKE :search OR
                                                  users.name LIKE :search OR
                                                  email LIKE :search OR
                                                  phone LIKE :search OR
                                                  company_name LIKE :search OR
                                                  company_email LIKE :search OR
                                                  short_bio LIKE :search OR
                                                  landmark LIKE :search OR
                                                  street_address LIKE :search OR
                                                  city LIKE :search OR
                                                  state_name LIKE :search OR
                                                  country_name LIKE :search OR
                                                  balance LIKE :search ',
                                                  search: wildcard_search).references(:categories)
    end

    if params[:category].present?
      category = Category.find_by_name params[:category]
      influencer_ids = category.users.pluck(:id)
      @influencers = @influencers.where(id: influencer_ids)
    end

    # @influencers = @influencers.where(industry: params[:social_media]) if params[:social_media].present?
    @influencers = @influencers.where(state: params[:state]) if params[:state].present?
    @influencers = @influencers.where(country: params[:country]) if params[:country].present?

    # if params[:price].present?
    #   price_range = Range.new(*params[:price].split('..').map(&:to_i))
    #   @influencers = @influencers.where(fb_average_cost: price_range)
    # end
    #
    # if params[:followers].present?
    #   followers = Range.new(*params[:followers].split('..').map(&:to_i))
    #   @influencers = @influencers.where(max_followers: followers)
    # end
    #
    #
    # @influencers = @influencers.order(:name).page(params[:page]).per(8)
    #
    # @influencers

    # send only selected influence's account
    @accounts = FacebookAccount.where(influencer_id: @influencers.pluck(:id)).page(params[:page]).per(8)
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
