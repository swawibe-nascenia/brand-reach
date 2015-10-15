class HelpsController < ApplicationController
  layout 'public'
  # before_action  :set_service, except: [:index]
  skip_before_filter :authenticate_user!

  respond_to :html
  def index
  end
end
