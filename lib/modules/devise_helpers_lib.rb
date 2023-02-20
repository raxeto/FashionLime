module Modules
  module DeviseHelpersLib

    protected

    def udpate_user_password(user)
      @user = User.find(user.id)
      if @user.update_with_password(user_password_params)
        # Sign in the user by passing validation in case their password changed
        sign_in @user, :bypass => true
        redirect_to after_update_password_path_for(@user), notice: I18n.t('devise.passwords.updated_not_active')
      else
        render :edit_password
      end
    end

    def update_user_profile(user)
      @show_password_field = false
      self.resource = User.find(user.id)
      pars = params[:user].permit(:username,
                 :email,
                 :email_o,
                 :current_password_o,
                 :first_name,
                 :last_name,
                 :gender,
                 :phone,
                 :avatar,
                 :birth_date,
                 :email_promotions)
      email = pars[:email] || pars[:email_o]
      if resource.username != pars[:username] || resource.email != email
        update do |resource|
          if resource.errors.key?(:current_password) || resource.errors.key?(:email) || resource.errors.key?(:username)
            @show_password_field = true
          end
        end
      else
        pars.delete(:email)
        pars.delete(:email_o)
        pars.delete(:current_password_o)
        pars.delete(:username)
        if resource.update_attributes(pars)
          sign_in resource, :bypass => true
          flash[:notice] = I18n.t('devise.registrations.updated')
          respond_with resource, location: after_update_profile_path_for(resource)
        else
          resource.email_o = resource.email
          respond_with resource
        end
      end
    end

  end
end
