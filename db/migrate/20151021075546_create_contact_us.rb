class CreateContactUs < ActiveRecord::Migration
  def change
    create_table :contact_us do |t|
      t.integer :category, default: 0
      t.string :message

      t.integer :user_id, null: false
    end
  end
end
