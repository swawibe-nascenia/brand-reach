class AddTypeToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :user_type, :integer, default: 0
    add_column :users, :gender, :string
  end
end
