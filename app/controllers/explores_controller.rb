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

    #get all account for selected influencer
    @accounts = FacebookAccount.where(influencer_id: @influencers.pluck(:id))

    if params[:price].present?
      price_range = Range.new(*params[:price].split('..').map(&:to_i))

      # Status Update => 0
      # Profile Photo => 1
      # Cover Photo => 2
      # Video Post => 3
      # Photo Post => 4
      @accounts = case params[:post_type].to_i
                    when 0 then @accounts.where(status_update_cost: price_range)
                    when 1 then @accounts.where(profile_photo_cost: price_range)
                    when 2 then @accounts.where(cover_photo_cost: price_range)
                    when 3 then @accounts.where(video_post_cost: price_range)
                    when 4 then @accounts.where(photo_post_cost: price_range)
                  end
    end

    if params[:followers].present?
      followers = Range.new(*params[:followers].split('..').map(&:to_i))
      @accounts = @accounts.where(number_of_followers: followers)
    end

    # send only selected influence's account
    @accounts = @accounts.page(params[:page]).per(8)
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
