class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!, :initialize_server_subscription, :check_profile_completion
  before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :check_profile_completion, if: :devise_controller?

  layout :layout_by_resource

  def after_sign_in_path_for(resource)
    if current_user.influencer? && current_user.sign_in_count <= 1
      profile_profile_index_path
    else
      profile_profile_index_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :user_type) }
  end

  def layout_by_resource
    if devise_controller?
      'public'
    else
      'application'
    end
  end

  def initialize_server_subscription
    $pubnub_server_subscription = Pubnub.new(
        :publish_key => CONFIG[:pubnub_publish_key], # publish_key only required if publishing.
        :subscribe_key => CONFIG[:pubnub_subscribe_key] # required always
    ) if $pubnub_server_subscription.blank?
  end

  def check_profile_completion
     unless current_user.profile_complete?
      flash[:error] = 'Please complete your profile page'
      redirect_to profile_profile_index_path
     end
  end

end
