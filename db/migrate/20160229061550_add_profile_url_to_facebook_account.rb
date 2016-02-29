class AddProfileUrlToFacebookAccount < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :profile_url, :string
  end
end
