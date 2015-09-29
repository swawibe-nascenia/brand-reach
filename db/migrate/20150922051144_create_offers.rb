class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.boolean :read
      t.boolean :starred
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :status
      t.string :message

      t.timestamps null: false
    end
  end
end
