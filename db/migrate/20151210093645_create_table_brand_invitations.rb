class CreateTableBrandInvitations < ActiveRecord::Migration
  def change
    create_table :brand_invitations do |t|
      t.timestamps null: false
      t.integer :status

      t.integer :brand_id, null: false
    end
  end
end
