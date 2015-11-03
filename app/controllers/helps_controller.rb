class HelpsController < ApplicationController
  layout 'public'

  skip_before_filter :authenticate_user!

  respond_to :html

  def index
  end
end
