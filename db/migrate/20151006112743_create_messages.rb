class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.boolean :read_by_sender
      t.boolean :read_by_receiver
      t.integer :campaign_id
      t.string :body

      t.timestamps null: false
    end
  end
end
