class BrandsController < ApplicationController

  def explore
  end

  def new_offer

  end

  def send_offer

  end

  private

  def offer_atttibutes
      params.require(:offer).permit(:sender_id, :receiver_id, :read, :starred, :status, :message)
  end
end
