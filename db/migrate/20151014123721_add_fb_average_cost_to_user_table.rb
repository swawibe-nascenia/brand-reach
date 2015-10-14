class AddFbAverageCostToUserTable < ActiveRecord::Migration
  def change
    add_column :users, :fb_average_cost, :integer
  end
end
