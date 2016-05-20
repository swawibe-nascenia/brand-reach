class ChangeFacebookAccountColumnType < ActiveRecord::Migration
  def change
    change_column :facebook_accounts, :status_update_cost, :integer, default: 0
    change_column :facebook_accounts, :profile_photo_cost, :integer, default: 0
    change_column :facebook_accounts, :cover_photo_cost, :integer, default: 0
    change_column :facebook_accounts, :video_post_cost, :integer, default: 0
    change_column :facebook_accounts, :photo_post_cost, :integer, default: 0
  end
end
