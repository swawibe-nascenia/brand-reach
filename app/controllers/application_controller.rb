class ApplicationController < ActionController::Base
  require 'csv'
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :authenticate_user!, :block_admin_user, :initialize_server_subscription, :check_profile_completion,
                :set_cache_buster, :check_profile_social_accounts
  before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :check_profile_completion, :check_profile_social_accounts, :block_admin_user, if: :devise_controller?

  layout :layout_by_resource

  def set_cache_buster
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  # override of device method that contain redirect logic after sing in
  def after_sign_in_path_for(resource)
    Rails.logger.info "Current user is #{current_user.user_type} and profile compete status is #{current_user.profile_complete?}"
    if current_user.super_admin?
      manage_admins_admin_admins_path
    elsif current_user.admin?
      profile_admin_admins_path
    elsif current_user.influencer? && current_user.profile_complete?
      insights_facebook_index_path
    elsif current_user.brand? && current_user.profile_complete?
      explores_path
    else
      profile_profile_index_path
    end
  end

  # pundit authorization error handling
  rescue_from Pundit::NotAuthorizedError do
    flash[:error] = 'Unauthorized access.'

    if current_user.super_admin?
      redirect_to manage_admins_admin_admins_path
    elsif current_user.admin?
      redirect_to profile_admin_admins_path
    else
      redirect_to root_path
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

      if current_user.influencer? && current_user.active_facebook_accounts.blank?
        error_messages << '* Connect your facebook account with value to complete your profile.'
      end

      User::BRAND_PROFILE_COMPLETENESS.each do |field|
         error_messages << "*  #{field.to_s.camelize(:lower)} is required field" unless current_user.send("#{field}?")
       end

       current_user.active_facebook_accounts.each do |facebook_account|
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

  def check_profile_social_accounts
    if current_user.try(:in_limbo?)
      redirect_to select_accounts_profile_index_path
    end
  end

  def block_admin_user
    if user_signed_in? && (current_user.admin? || current_user.super_admin?)
      redirect_to after_sign_in_path_for(current_user)
    end
  end
end
