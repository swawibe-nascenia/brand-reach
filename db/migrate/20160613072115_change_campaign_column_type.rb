class ChangeCampaignColumnType < ActiveRecord::Migration
  def change
    change_column :campaigns, :text, :text
  end
end
