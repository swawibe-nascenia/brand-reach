class BankAccountsController < ApplicationController

  respond_to :html, :js

  def new
    @bank_account = BankAccount.new
  end

  def create
    @bank_account = BankAccount.new(bank_accounts_params)
    @bank_account.user_id = current_user.id

    if  @bank_account.save
      redirect_to influencer_payment_influencer_payments_path
    end
  end

  def destroy
    @bank_account = BankAccount.find(params[:id])
    @bank_account.destroy
    respond_to do |format|
      format.html { redirect_to influencer_payment_influencer_payments_path, notice: 'Bank Account was successfully destroyed.' }
    end
  end

  private

  def bank_accounts_params
    params.require(:bank_account).permit(:bank_name, :address, :city, :state, :zip, :country, :account_name,
                                         :account_number, :currency, :routing_number, :bic, :iban
    )
  end

end
