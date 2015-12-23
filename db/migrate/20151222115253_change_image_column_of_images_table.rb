class ChangeImageColumnOfImagesTable < ActiveRecord::Migration
  def change
    rename_column :images, :image, :image_path
  end
end
