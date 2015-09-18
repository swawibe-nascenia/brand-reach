class CreatTableFacebooks < ActiveRecord::Migration
  def change
    create_table :facebooks do |t|
      t.string :uid, null: false
      t.string :access_token, null: false
      t.datetime :token_expires_at, null: false

    #   user pricing specific info
      t.integer :status_update_price, default: 0
      t.integer :profile_photo_price, default: 0
      t.integer :checkin_price, default: 0
      t.integer :video_post_price, default: 0
      t.integer :banner_photo_price, default: 0
      t.integer :line_price, default: 0

    #   for relationship with user model
      t.integer :influencer_id, null: false
    end
  end
end
