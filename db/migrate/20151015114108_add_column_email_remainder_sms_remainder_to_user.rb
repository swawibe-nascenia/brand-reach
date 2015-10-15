class AddColumnEmailRemainderSmsRemainderToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_remainder_active, :boolean, default: 1
    add_column :users, :sms_remainder_active, :boolean, default: 1
  end
end
