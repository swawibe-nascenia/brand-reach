class CreateBankAccount < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :bank_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :account_name
      t.string :account_number
      t.string :currency
      t.string :routing_number
      t.string :bic
      t.string :iban

      t.integer :user_id, null: false
    end
  end
end
