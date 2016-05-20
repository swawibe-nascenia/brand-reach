class AddInfluencerTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :influencer_type, :integer, default: 0
  end
end
