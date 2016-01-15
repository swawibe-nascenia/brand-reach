class InfluencersController < ApplicationController

  before_action :set_influencer, only: [:show]

  respond_to :html, :js

  def show
    respond_with(@influencer)
  end

  def search
    wildcard_search = "%#{params[:search_key].strip! || params[:search_key]}%"
    all_offers_key = current_user.campaigns_received
                         .where.not(deleted_by_influencer: true, deleted_by_brand: true)
                         .pluck(:id)

    @campaigns = Campaign.where(id: all_offers_key)
                         .includes(:messages)
                         .where('messages.body LIKE :search OR
                                 campaigns.name LIKE :search OR
                                 campaigns.text LIKE :search OR
                                 campaigns.headline LIKE :search',
                                search: wildcard_search).references(:messages)

    @influencers = User.active_influencers.includes(:categories).where('categories.name LIKE :search OR
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
                                             .where(id: current_user.id)
  end

  private

  def set_influencer
    @influencer = User.find(params[:id])
  end
end
