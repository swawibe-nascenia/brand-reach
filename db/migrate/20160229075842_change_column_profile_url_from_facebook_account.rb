class ChangeColumnProfileUrlFromFacebookAccount < ActiveRecord::Migration
  def change
    rename_column :facebook_accounts, :profile_url, :profile_picture_url
  end
end
