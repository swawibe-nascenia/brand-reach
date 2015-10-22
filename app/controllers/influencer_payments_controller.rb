class InfluencerPaymentsController < ApplicationController

  respond_to :html, :js

  def index
    @transactions = current_user.influencer_payments
    @bank_accounts = current_user.bank_accounts
  end

  def withdraw_payment
    if current_user.balance >= params[:amount].to_i
      influencer_payment = current_user.influencer_payments.create(amount_billed: params[:amount].to_i, bank_account_id: params[:bank_account_id], billed_date: Time.now)

      if influencer_payment.valid?
        new_balance = current_user.balance - params[:amount].to_i
        current_user.update_column(:balance, new_balance)
        current_user.save
        flash[:success] = 'Your withdraw request successfully send.'
      else
        flash[:error] = 'Your withdraw request has been failed.'
      end
    else
      flash[:error] = 'Un-sufficient withdraw balance'
    end
  end

  def export_payments
    payment_ids = params[:payment_ids]
  end

end
