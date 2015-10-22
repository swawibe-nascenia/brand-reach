class ChangeCampaignsSocialAccountActivityIdToText < ActiveRecord::Migration
  def change
    change_column :campaigns, :social_account_activity_id, :string, default: nil
  end
end
