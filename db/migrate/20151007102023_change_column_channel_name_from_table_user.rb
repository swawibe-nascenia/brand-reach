class ChangeColumnChannelNameFromTableUser < ActiveRecord::Migration
  def change
    change_column :users, :channel_name, :string, null: true
  end
end
