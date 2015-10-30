class SessionsController < Devise::SessionsController
  respond_to :html, :json, :js

  def create
    self.resource = warden.authenticate(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    @login_success = true

    if resource
      Rails.logger.info "------------------- current sign in success for #{ self.resource.inspect }"
      sign_in(resource_name, resource)
    else
      Rails.logger.info "------------------- current sign in fail for #{ self.resource.inspect }"
      @login_success = false
    end

  end
end
