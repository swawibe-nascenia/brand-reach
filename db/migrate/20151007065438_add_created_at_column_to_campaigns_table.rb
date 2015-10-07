class AddCreatedAtColumnToCampaignsTable < ActiveRecord::Migration
  def change
    change_table(:campaigns) { |t| t.timestamps null: false }
  end
end
