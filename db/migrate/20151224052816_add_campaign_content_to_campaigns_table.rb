class AddCampaignContentToCampaignsTable < ActiveRecord::Migration
  def change
    add_column :campaigns, :campaign_content, :string
  end
end
