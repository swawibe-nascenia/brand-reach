class AddColumnDeniedAtToTableCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :denied_at, :datetime
  end
end
