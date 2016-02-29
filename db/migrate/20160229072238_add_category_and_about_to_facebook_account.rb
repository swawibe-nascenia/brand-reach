class AddCategoryAndAboutToFacebookAccount < ActiveRecord::Migration
  def change
    add_column :facebook_accounts, :category, :string
    add_column :facebook_accounts, :about, :string
  end
end
