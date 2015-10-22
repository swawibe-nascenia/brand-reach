class AddFacebookAccountIdToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :facebook_account_id, :integer, null: false
  end
end
