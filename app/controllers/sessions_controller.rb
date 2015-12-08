class SessionsController < Devise::SessionsController
  respond_to :html, :json, :js
  layout 'public'

  def create
    temp_user = User.find_by_email(params[:user]['email'])

    @login_success = false
    @messages = []
    Rails.logger.info "------------------- temporary user by email #{ temp_user.inspect }"

    if temp_user
      if temp_user.verified?
        #   verified user by brandreach
        user = warden.authenticate(auth_options)

        if user
          # authentication success
          Rails.logger.info "------------------- current sign in success for #{ user.inspect }"
          @login_success = true
          sign_in(resource_name, user)

          unless user.is_active?
            user.update_attribute(:is_active, true)
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
    else
      #   user not found by email
      if params[:admin].present?
        flash[:error] = 'This e-mail ID was not found.'
        redirect_to admin_path
      else
        respond_to do |format|
          format.js { @messages << 'This e-mail ID was not found.' }
          format.html { flash.now[:error] = 'This e-mail ID was not found.' }
        end
      end

    end
  end
end
