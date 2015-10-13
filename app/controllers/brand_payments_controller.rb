class BrandPaymentsController < ApplicationController

  respond_to :html, :js

  def brand_payment
    @transactions = BrandPayment.all
  end

  def export_payments
    payment_ids = params[:payment_ids]
  end

end
