class AddPhotoPostCostToFacebookAccounts < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :photo_post_cost, :integer
  end
end
