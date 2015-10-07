class OffersController < ApplicationController
  before_action :set_offer, only: [:show, :edit, :update, :destroy, :accept, :deny, :undo_deny]

  # GET /offers
  # GET /offers.json
  def index
    if current_user.influencer?
      @offers = current_user.campaigns_received
      @stared_offers = current_user.campaigns_received.where(starred_by_influencer: true)
    else
      @offers = current_user.campaigns_sent
      @stared_offers = current_user.campaigns_sent.where(starred_by_brand: true)
    end
  end

  # GET /offers/1
  # GET /offers/1.json
  def show
  end

  # GET /offers/new
  def new
    @offer = Offer.new
  end

  # GET /offers/1/edit
  def edit
  end

  # POST /offers
  # POST /offers.json
  def create
    @offer = Offer.new(offer_params)

    respond_to do |format|
      if @offer.save
        format.html { redirect_to @offer, notice: 'Offer was successfully created.' }
        format.json { render :show, status: :created, location: @offer }
      else
        format.html { render :new }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /offers/1
  # PATCH/PUT /offers/1.json
  def update
    respond_to do |format|
      if @offer.update(offer_params)
        format.html { redirect_to @offer, notice: 'Offer was successfully updated.' }
        format.json { render :show, status: :ok, location: @offer }
      else
        format.html { render :edit }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offers/1
  # DELETE /offers/1.json
  def destroy
    @offer.destroy
    respond_to do |format|
      format.html { redirect_to offers_url, notice: 'Offer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # take array of offer ids and make those stared
  #  target_column may be 'starred_by_brand' of 'starred_by_influencer'
  def toggle_star
    target_column = current_user.brand? ? :starred_by_brand : :starred_by_influencer
    ids = params[:ids].map(&:to_i)
    offers = Campaign.where(id: ids)

    if offers.count == offers.where(target_column => true).count
      # all offers are stared
      reset_star(offers, target_column)
    elsif offers.count == offers.where(target_column => false).count
      # all offers are non stared
      set_star(offers, target_column)
    else
      # make all stared
      set_star(offers, target_column)
    end

    # redirect_to offers_path
  end

  def accept
    @offer.update_attribute(:status, Campaign.statuses[:accepted])
  end

  def deny
    @offer.update_attributes({status: Campaign.statuses[:denied], denied_at: Time.now })
  end

  def undo_deny
    @offer.update_attribute(:status, Campaign.statuses[:waiting])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offer
      @offer = Campaign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def offer_params
      params[:campaign]
    end

  def set_star(offers, target_column)
    offers.update_all(target_column => true)
  end

  def reset_star(offers, target_column)
    offers.update_all(target_column => false)
  end
end
