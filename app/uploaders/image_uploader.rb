# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process :crop
    process :resize_to_fill => [160, 160]
  end

  version :medium do
    process :crop
    process :resize_to_fit => [250, 250]
  end

  version :explore_image do
    process :crop
    process :resize_to_fit => [nil, 120]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  def extension_white_list
      %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  private

  def crop
      if(model.crop_x.present? && model.crop_y.present? && model.crop_w.to_i > 10 && model.crop_h.to_i > 10)
        # resize_to_limit(400, 400)
        Rails.logger.info " Image ... crop with in image uploader x: #{model.crop_x} y: #{model.crop_y} w: #{model.crop_w} h: #{model.crop_h}"
        #Commented out code for RMagick
        manipulate! do |image|
          # image.crop!(model.crop_x.to_i, model.crop_y.to_i, model.crop_w.to_i, model.crop_h.to_i)#RMagick
          image.crop("#{model.crop_w.to_i}x#{model.crop_h.to_i}+#{model.crop_x.to_i}+#{model.crop_y.to_i}")#Minimagick
          image
        end
      end
  end
end
