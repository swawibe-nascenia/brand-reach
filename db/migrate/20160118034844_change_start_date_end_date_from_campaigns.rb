class ChangeStartDateEndDateFromCampaigns < ActiveRecord::Migration
  def change
    change_column :campaigns, :start_date, :datetime
    change_column :campaigns, :end_date, :datetime
  end
end
