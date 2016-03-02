class ChangeFacebookAccountsIdColumnToCategoriesFacebookAccountsTable < ActiveRecord::Migration
  def change
    rename_column :categories_facebook_accounts, :facebook_accounts_id, :facebook_account_id
  end
end
