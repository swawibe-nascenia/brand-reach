class BankAccountsController < ApplicationController
  respond_to :html, :js

  def new
    @bank_account = BankAccount.new
  end

  def create
    @bank_account = BankAccount.new(bank_account_params)
    @bank_account.user_id = current_user.id
    @is_save = @bank_account.save
  end

  def destroy
    @bank_account = BankAccount.find(params[:id])
    @bank_account.destroy

    respond_to do |format|
      format.html {
        redirect_to influencer_payments_path,
                    notice: 'Bank Account was successfully destroyed.'
      }
    end
  end

  private

  def bank_account_params
    params.require(:bank_account).permit(:bank_name, :address, :city, :state,
      :zip, :country, :account_name, :account_number, :currency,
      :routing_number, :bic, :iban)
  end
end
