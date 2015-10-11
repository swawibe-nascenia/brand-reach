class PaymentTransactionsController < ApplicationController

  respond_to :html, :js

  def brand_payment
    @transactions = PaymentTransaction.all
  end

  def influencer_payment
    @transactions = PaymentTransaction.all
    @bank_accounts = BankAccount.all
  end

  def export_payments
    payment_ids = params[:payment_ids]
  end

end
