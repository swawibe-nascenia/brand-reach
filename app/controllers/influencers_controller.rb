class InfluencersController < ApplicationController

  before_action :set_influencer, only: [:show]

  respond_to :html, :js

  def show
    respond_with(@influencer)
  end

  def search
    wildcard_search = "%#{params[:search_key].strip! || params[:search_key]}%"
    all_offers_key = current_user.campaigns_received.where.not(deleted_by_influencer: true).pluck(:id)
    @messages = Message.where(campaign_id: all_offers_key).where('body LIKE :search', search: wildcard_search).includes(:campaign)
    #TODO @influencers = @influencers.where('industry LIKE :search OR country_name LIKE :search OR state_name LIKE :search', search: wildcard_search)
  end

  private

  def set_influencer
    @influencer = User.find(params[:id])
  end
end
