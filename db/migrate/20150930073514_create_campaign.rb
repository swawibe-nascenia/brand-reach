class CreateCampaign < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :text
      t.string :headline
      t.string :social_account_page_name
      t.date :start_date
      t.date :end_date
      t.boolean :campaign_active, default: 1
      t.integer :cost, default: 0
      t.integer :social_account_activity_id, default: 0
      t.integer :post_type, default: 0
      t.integer :number_of_likes, default: 0
      t.integer :number_of_post_reach, default: 0
      t.integer :number_of_comments, default: 0
      t.integer :number_of_shares, default: 0
      t.string :card_number
      t.integer :card_expiration_month
      t.integer :card_expiration_year
      t.string :card_holder_name
      t.integer :schedule_type, default: 0

      t.integer :offer_id, null: false
    end
  end
end
