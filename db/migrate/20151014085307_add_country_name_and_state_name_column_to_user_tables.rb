class AddCountryNameAndStateNameColumnToUserTables < ActiveRecord::Migration
  def change
    add_column :users, :country_name, :string
    add_column :users, :state_name, :string
  end
end
