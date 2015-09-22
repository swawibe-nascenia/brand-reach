class BrandsController < ApplicationController

  def explore
    if brand_user?
      @influncers = User.influencers.order(:name).page params[:page]
    else
      redirect_to :back
    end
  end

  private

  def brand_user?
    current_user.user_type == 'brand' ? true : false
  end
end
