class ChangeColumnStatusToOffersTable < ActiveRecord::Migration
  def change
    change_column :offers, :status, :integer, default: 0
  end
end
