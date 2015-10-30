class ApplicationController < ActionController::Base
  require 'csv'
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
    error_messages = []

    unless current_user.profile_complete?
      error_messages << 'Please complete your profile to use other pages'
      error_messages << '* Connect your facebook account with all fields complete' if current_user.facebook_accounts.blank?

      User::BRAND_PROFILE_COMPLETENESS.each do |field|
         error_messages << "*  #{field.to_s.camelize(:lower)} is required field" unless current_user.send("#{field}?")
       end

       current_user.facebook_accounts.each do |facebook_account|
         User::FACEBOOK_ACCOUNT_COMPLETENESS.each do |field|
           unless facebook_account.send("#{field}").present?
             error_messages << "*  #{field.to_s.camelize} of #{facebook_account.name} is required field" unless facebook_account.send("#{field}").present?
           end
         end
       end

      flash[:error] = error_messages
      redirect_to profile_profile_index_path
     end
  end

end
