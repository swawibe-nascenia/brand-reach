class AddColumnAccessTokenAndTokenExpiresAtToSocialAccountsTable < ActiveRecord::Migration
  def change
    add_column :social_accounts, :token_expires_at, :datetime
  end
end
