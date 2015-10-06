class AddColumnChannelNameToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :channel_name, :string, null: false
  end
end
