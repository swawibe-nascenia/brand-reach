class BrandPaymentsController < ApplicationController

  respond_to :html, :js

  def brand_payment
    @transactions = BrandPayment.where(campaign_id: current_user.campaigns_sent.ids)
  end

  def export_payments
    payment_ids = params[:payment_ids]
  end

end
