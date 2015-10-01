class ChangeColumnStarredToStarredBySender < ActiveRecord::Migration
  def change
    remove_column :offers, :starred, :boolean
    add_column :offers, :starred_by_brand, :boolean, default: false
    add_column :offers, :starred_by_influencer, :boolean, default: false
  end
end
