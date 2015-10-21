class ChangeColumnTransactionIdToTableInfluencerPaymentTable < ActiveRecord::Migration
  def change
    change_column :influencer_payments, :transaction_id, :string
  end
end
