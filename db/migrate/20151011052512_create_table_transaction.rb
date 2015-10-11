class CreateTableTransaction < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|

      t.date :billed_date
      t.integer :amount_billed, default: 0
      t.integer :status, default: 0
      t.integer :transaction_id, default: 0

      t.integer :campaign_id, null: false
    end
  end
end
