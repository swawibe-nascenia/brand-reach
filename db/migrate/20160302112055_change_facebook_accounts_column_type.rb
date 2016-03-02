class ChangeFacebookAccountsColumnType < ActiveRecord::Migration
  def change
    change_column :facebook_accounts, :profile_picture_url, :text
  end
end
