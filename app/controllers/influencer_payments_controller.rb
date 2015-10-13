class InfluencerPaymentsController < ApplicationController

  respond_to :html, :js

  def influencer_payment
    @transactions = InfluencerPayment.all
    @bank_accounts = BankAccount.all
  end

  def export_payments
    payment_ids = params[:payment_ids]
  end

end
