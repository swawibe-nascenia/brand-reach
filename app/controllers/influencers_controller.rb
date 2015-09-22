class InfluencersController < ApplicationController

  before_action :set_influencer, only: [:show]

  respond_to :html, :js

  def show
    respond_with(@influencer)
  end

  private

  def set_influencer
    @influencer = User.find(params[:id])
  end
end
