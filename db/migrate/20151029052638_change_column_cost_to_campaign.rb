class ChangeColumnCostToCampaign < ActiveRecord::Migration
  def change
    change_column :campaigns, :cost, :integer, default: nil
  end
end
