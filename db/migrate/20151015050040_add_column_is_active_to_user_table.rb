class AddColumnIsActiveToUserTable < ActiveRecord::Migration
  def change
      add_column :users, :is_active, :boolean, default: 1
  end
end
