class AddUrlColumnToFacebookAccountsTable < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :url, :string
  end
end
