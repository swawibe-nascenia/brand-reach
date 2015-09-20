class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!

  layout :layout_by_resource

  def after_sign_in_path_for(resource)
    if current_user.influencer? && current_user.sign_in_count <= 1

    else
      profile_profile_index_path
    end
  end

  protected

  def layout_by_resource
    if devise_controller?
      'public'
    else
      'application'
    end
  end

end
