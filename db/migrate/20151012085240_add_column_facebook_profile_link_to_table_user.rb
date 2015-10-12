class AddColumnFacebookProfileLinkToTableUser < ActiveRecord::Migration
  def change
    add_column :users, :facebook_profile_url, :string
  end
end
