class AddColumnDenyAtToOffersTable < ActiveRecord::Migration
  def change
    add_column :offers, :denied_at, :datetime
  end
end
