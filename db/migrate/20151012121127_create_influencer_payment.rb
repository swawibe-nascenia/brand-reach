class CreateInfluencerPayment < ActiveRecord::Migration
  def change
    create_table :influencer_payments do |t|

        t.date :billed_date
        t.integer :amount_billed, default: 0
        t.integer :status, default: 0
        t.integer :transaction_id, default: 0

        t.integer :user_id, null: false
        t.integer :bank_account_id, null: false
    end
  end
end
