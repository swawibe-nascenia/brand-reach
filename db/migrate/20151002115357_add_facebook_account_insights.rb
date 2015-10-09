class AddFacebookAccountInsights < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :number_of_followers, :integer
    add_column :facebook_accounts, :daily_page_views, :integer
    add_column :facebook_accounts, :number_of_posts, :integer
    add_column :facebook_accounts, :post_reach, :integer
  end
end
