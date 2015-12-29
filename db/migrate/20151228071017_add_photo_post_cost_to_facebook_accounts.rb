class AddPhotoPostCostToFacebookAccounts < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :photo_post_cost, :integer
  end

  FacebookAccount.all.update_all(:photo_post_cost => 10)
end
