class ChangeColumnTypeCategoryToContactUs < ActiveRecord::Migration
  def change
    change_column :contact_us, :category, :string, default: nil
  end
end