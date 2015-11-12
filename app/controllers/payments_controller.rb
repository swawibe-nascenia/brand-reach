class PaymentsController < ApplicationController
  respond_to :html, :js

  def index
    if current_user.brand?
      brand_index
    else
      influencer_index
    end
  end

  def export
    if current_user.brand?
      export_brand_payments
    else
      export_influencer_payments
    end
  end

  def withdraw
    influencer_withdraw_payment
  end

  private

  def brand_index
    @transactions = BrandPayment.where(campaign_id: current_user.campaigns_sent.pluck(:id))
    render 'payments/brand_index'
  end

  def export_brand_payments
    if params[:payment_ids].present?
      payment_ids = params[:payment_ids].split(',').uniq
      @brand_payments = BrandPayment.where(id: payment_ids)
    else
      @brand_payments = BrandPayment.where(campaign_id: current_user.campaigns_sent.ids)
    end

    respond_to do |format|
      format.html{ render 'payments/export_brand_payments' }
      format.csv do
        #  Don't Try to Put Headers into single line, it wont work
        headers['Content-Disposition'] = "attachment; filename=\"payments_list_brand.csv\""
        headers['Content-Type'] ||= 'text/csv'
        render 'payments/export_brand_payments'
      end
    end
  end

  def influencer_index
    @transactions = current_user.influencer_payments
    @bank_accounts = current_user.bank_accounts
    render 'payments/influencer_index'
  end

  def influencer_withdraw_payment
    if params[:amount].to_i > 0 && current_user.balance >= params[:amount].to_i
      influencer_payment = current_user.influencer_payments.create(
          amount_billed: params[:amount].to_i, bank_account_id: params[:bank_account_id],
          billed_date: Time.now)

      if influencer_payment.valid?
        new_balance = current_user.balance - params[:amount].to_i
        current_user.update_column(:balance, new_balance)
        current_user.save
        flash[:success] = 'Your withdraw request successfully send.'
      else
        flash[:error] = 'Your withdraw request has been failed.'
      end
    else
      flash[:error] = 'Insufficient/wrong withdraw balance'
    end

    render 'payments/withdraw_payment'
  end

  def export_influencer_payments
    if params[:payment_ids].present?
      payment_ids = params[:payment_ids].split(',').uniq
      @influencer_payments = InfluencerPayment.where(id: payment_ids)
    else
      @influencer_payments = current_user.influencer_payments
    end

    respond_to do |format|
      format.html{ render 'payments/export_influencer_payments' }
      format.csv do
        #  Don't Try to Put Headers into single line, it wont work
        headers['Content-Disposition'] = "attachment; filename=\"payments_list_influencer.csv\""
        headers['Content-Type'] ||= 'text/csv'
        render 'payments/export_influencer_payments'
      end
    end
  end
end
