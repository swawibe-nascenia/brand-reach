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
    @transactions = BrandPayment.where(campaign_id: current_user.campaigns_sent.pluck(:id)).order('id DESC')
    render 'payments/brand_index'
  end

  def export_brand_payments
    if params[:payment_ids].present?
      payment_ids = params[:payment_ids].split(',').uniq
      # TODO need to change before deploy to staging
      # @brand_payments = BrandPayment.where(id: payment_ids)
      campaign_ids = Campaign.engaged_campaigns_from(current_user).pluck(:id)
      @brand_payments = BrandPayment.where(campaign_id: campaign_ids, id: payment_ids).order('id DESC')
    else
      @brand_payments = BrandPayment.where(campaign_id: campaign_ids).order('id DESC')
    end

    @footer_text = "All Rights Reserved \u00AE Brand Reach | Copyright #{Time.now.year}"

    respond_to do |format|
      format.html{ render 'payments/export_brand_payments' }
      format.pdf do
        headers['Content-Disposition'] = "filename=\"payments_list_brand_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.pdf\""
        render 'payments/export_brand_payments'
      end
      format.csv do
        #  Don't Try to Put Headers into single line, it wont work
        headers['Content-Disposition'] = "attachment; filename=\"payments_list_brand_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.csv\""
        headers['Content-Type'] ||= 'text/csv'
        render 'payments/export_brand_payments'
      end
      format.xls do
        headers['Content-Disposition'] = "attachment; filename=\"payments_list_brand_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.xls\""
        render 'payments/export_brand_payments'
      end
    end
  end

  def influencer_index
    @transactions = current_user.influencer_payments.order('id DESC')
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
      @influencer_payments = current_user.influencer_payments.where(id: payment_ids).order('id DESC')
    else
      @influencer_payments = current_user.influencer_payments.order('id DESC')
    end

    @footer_text = "All Rights Reserved \u00AE Brand Reach | Copyright #{Time.now.year}"

    respond_to do |format|
      format.html{ render 'payments/export_influencer_payments' }
      format.pdf do
        headers['Content-Disposition'] = "filename=\"payments_list_influencer_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.pdf\""
        render 'payments/export_influencer_payments'
      end
      format.csv do
        #  Don't Try to Put Headers into single line, it wont work
        headers['Content-Disposition'] = "attachment; filename=\"payments_list_influencer_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.csv\""
        headers['Content-Type'] ||= 'text/csv'
        render 'payments/export_influencer_payments'
      end
      format.xls do
        headers['Content-Disposition'] = "attachment; filename=\"payments_list_influencer_#{Time.now.strftime('%Y%m%d_%H_%M_%S')}.xls\""
        render 'payments/export_influencer_payments'
      end
    end
  end
end
