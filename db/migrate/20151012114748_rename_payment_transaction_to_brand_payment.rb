class RenamePaymentTransactionToBrandPayment < ActiveRecord::Migration
  def change
    rename_table :payment_transactions, :brand_payments
  end
end
