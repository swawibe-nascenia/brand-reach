class ChangeColumnBilledDateFromTableInfluencerPayment < ActiveRecord::Migration
  def change
    change_column :influencer_payments, :billed_date, :datetime
  end
end
