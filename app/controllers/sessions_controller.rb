class SessionsController < Devise::SessionsController
  respond_to :html, :json, :js
  layout 'public'

  def new
    redirect_to root_path(sign_in_modal: true)
  end

  def create
    temp_user = User.find_by_email(params[:user]['email'])

    @login_success = false
    @messages = []
    Rails.logger.info "------------------- temporary user by email #{ temp_user.inspect }"

    if temp_user
      if (params[:admin].present? && (temp_user.brand? || temp_user.influencer?))
        Rails.logger.info "No authority "
        flash[:error] = 'You are unauthorized to access the page.'
        redirect_to admin_path
      else
        if temp_user.active? || temp_user.inactive?
          #   verified user by brandreach
          user = warden.authenticate(auth_options)

          if user
            # authentication success
            Rails.logger.info "------------------- current sign in success for #{ user.inspect }"
            @login_success = true
            sign_in(resource_name, user)

            # make active to in-active user
            unless user.active?
              user.update_attribute(:status, User.statuses[:active])
            end

            respond_to do |format|
              format.js { }
              format.html { redirect_to after_sign_in_path_for(resource) }
            end
          else
            #   authentication fail
            Rails.logger.info "------------------- current sign in authentication fail for #{ user.inspect }"
            if params[:admin].present?
              flash[:error] = 'Email, password not matching'
              redirect_to admin_path
            else
              respond_to do |format|
                format.js { @messages << 'Email, password not matching' }
                format.html { flash.now[:error] = 'Email, password not matching' }
              end
            end
          end
        else
          #   un verified user
          respond_to do |format|
            format.js { @messages << 'Your account is not active yet' }
            format.html { flash.now[:error] = 'Your account is not active yet' }
          end
        end
      end
    else
      #   user not found by email
      if params[:admin].present?
        flash[:error] = 'This email address was not found.'
        redirect_to admin_path
      else
        respond_to do |format|
          format.js { @messages << 'This email address was not found.' }
          format.html { flash.now[:error] = 'This email address was not found.' }
        end
      end

    end
  end

  def destroy
    if current_user.present? && current_user.influencer?
      if current_user.active_facebook_accounts.count < 1
        current_user.update_column(:status, User.statuses[:in_limbo])
      end
    end
    session[:admin_or_super_admin] = current_user
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    # set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
    yield if block_given?
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
    end
  end
end
