class ChangeUsersShortBioToText < ActiveRecord::Migration
  def change
    change_column :users, :short_bio, :text
  end
end
