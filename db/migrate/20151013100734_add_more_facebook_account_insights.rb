class AddMoreFacebookAccountInsights < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :likes_by_country, :text
    add_column :facebook_accounts, :reach_by_country, :text
    add_column :facebook_accounts, :likes_by_city, :text
    add_column :facebook_accounts, :reach_by_city, :text
    add_column :facebook_accounts, :likes_by_gender_age_month, :text
    add_column :facebook_accounts, :likes_by_gender_age_week, :text
  end
end
