class CreateTableCategoriesFacebookAccounts < ActiveRecord::Migration
  def change
    create_table :categories_facebook_accounts, id: false do |t|
      t.belongs_to :facebook_accounts, index: true
      t.belongs_to :category, index: true
    end
  end
end
