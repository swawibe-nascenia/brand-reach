class ExploresController < ApplicationController
  def show
    if current_user.brand?
      @influncers = User.influencers.order(:name).page params[:page]
    else
      redirect_to :back
    end
  end
end
