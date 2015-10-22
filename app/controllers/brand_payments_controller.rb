class BrandPaymentsController < ApplicationController

  respond_to :html, :js

  def index
    @transactions = BrandPayment.where(campaign_id: current_user.campaigns_sent.pluck(:id))
  end

  def export_payments
    payment_ids = params[:payment_ids]
  end

end
