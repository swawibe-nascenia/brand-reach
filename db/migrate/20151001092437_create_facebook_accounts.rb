class CreateFacebookAccounts < ActiveRecord::Migration
  def change
    create_table :facebook_accounts do |t|
      t.string :name
      t.string :account_id

      t.integer :influencer_id, null: false

      t.string :access_token, null: false
      t.datetime :token_expires_at, null: false

      t.string :status_update_cost
      t.string :profile_photo_cost
      t.string :cover_photo_cost
      t.string :video_post_cost

      t.timestamps null: false
    end
  end
end
