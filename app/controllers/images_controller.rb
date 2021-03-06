class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :destroy]
  respond_to :js, :html

  def create
    @image = Image.new(image_params)
    @success = false

    if @image.save
      @success = true
    end
  end

  def show
  end

  def destroy
    @image.destroy
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:image_path, :message_id)
  end
end
