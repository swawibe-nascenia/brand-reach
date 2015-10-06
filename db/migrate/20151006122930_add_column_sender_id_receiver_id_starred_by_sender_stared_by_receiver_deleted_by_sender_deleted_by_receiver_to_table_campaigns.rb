class AddColumnSenderIdReceiverIdStarredBySenderStaredByReceiverDeletedBySenderDeletedByReceiverToTableCampaigns < ActiveRecord::Migration
  def change
    remove_column :campaigns, :offer_id

    add_column :campaigns, :status, :integer, default: 0
    add_column :campaigns, :sender_id, :integer
    add_column :campaigns, :receiver_id, :integer
    add_column :campaigns, :starred_by_brand, :boolean, default: false
    add_column :campaigns, :starred_by_influencer, :boolean, default: false
    add_column :campaigns, :deleted_by_brand, :boolean, default: false
    add_column :campaigns, :deleted_by_influencer, :boolean, default: false
  end
end
