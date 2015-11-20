class AddMaxFollowersColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :max_followers, :integer
    add_index :users, :max_followers
  end
end
