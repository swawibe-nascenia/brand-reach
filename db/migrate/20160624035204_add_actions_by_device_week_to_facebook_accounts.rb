class AddActionsByDeviceWeekToFacebookAccounts < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :actions_by_gender_age_week, :text
    add_column :facebook_accounts, :actions_by_device_week, :text
  end
end
