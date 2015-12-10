class CreateContactUsCategory < ActiveRecord::Migration
  def change
    create_table :contact_us_categories do |t|
      t.string :name
    end
  end
end
