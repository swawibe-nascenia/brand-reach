class AddActionColumnsToFacebookAccounts < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :total_action_button_clicks, :text
    add_column :facebook_accounts, :total_people_action_button_clicks, :text
  end
end
