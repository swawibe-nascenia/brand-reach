class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.string :username

      t.timestamps null: false
    end
    add_index :pages, :username
  end
end
