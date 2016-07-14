class AddPostClickColumnsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :post_click_number, :integer, default: 0
    add_column :campaigns, :post_link_click_number, :integer, default: 0
  end
end
