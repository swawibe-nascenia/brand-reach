class BrandPaymentsController < ApplicationController

  respond_to :html, :js

  def index
    @transactions = BrandPayment.where(campaign_id: current_user.campaigns_sent.pluck(:id))
  end

  def export_brand_payments
    if params[:payment_ids].present?
      payment_ids = params[:payment_ids].split(',').uniq
      @brand_payments = BrandPayment.where(id: payment_ids)
    else
      @brand_payments = BrandPayment.where(campaign_id: current_user.campaigns_sent.ids )
    end

    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"payments_list_brand.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end
end
