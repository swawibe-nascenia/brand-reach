class AddInsightsUpdatedAtToFacebookAccounts < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :insights_updated_at, :datetime
  end
end
