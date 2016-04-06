class AddNumberOfPostReachToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :number_of_post_reach_of_post, :integer, default: 0
  end
end
