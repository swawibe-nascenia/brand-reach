class BrandsController < ApplicationController

  def explore
    if brand_user?
      @influncers = User.influencers.order(:name).page params[:page]
    else
      redirect_to :back
    end
  end

  def brand_user?
    current_user.user_type == 'brand' ? true : false
  end

  def new_offer

  end

  def send_offer
    offer = Offer.new(offer_atttibutes)
    offer.sender_id = current_user.id
    @success = true
    unless offer.save
      @success = false
    end
  end

  private

  def offer_atttibutes
      params.require(:offer).permit(:sender_id, :receiver_id, :read, :starred, :status, :message)
  end
end
