class CreateCampaign < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :campaign_name
      t.string :campaign_text
      t.string :campaign_headline
      t.string :social_account_page_name
      t.date :campaign_start_date
      t.date :campaign_end_date
      t.boolean :campaign_active, default: 1
      t.integer :campaign_cost, default: 0
      t.integer :social_account_activity_id, default: 0
      t.integer :campaign_post_type, default: 0
      t.integer :number_of_likes, default: 0
      t.integer :number_of_post_reach, default: 0
      t.integer :number_of_comments, default: 0
      t.integer :number_of_shares, default: 0
      t.string :card_number
      t.integer :card_expiration_month, default: 0
      t.integer :card_expiration_year
      t.string :card_holder_name
      t.integer :schedule_type, default: 0

      t.integer :offer_id, null: false
    end
  end
end
