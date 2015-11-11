class AddIsActiveToFacebookAccounts < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :is_active, :boolean, default: true
  end
end
