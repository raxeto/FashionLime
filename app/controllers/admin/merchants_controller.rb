class Admin::MerchantsController < AdminController

  def new
    @user = User.new
    @merchant = Merchant.new
  end

  def create
    error = false
    ActiveRecord::Base.transaction do
      @merchant = Merchant.create(name: params[:merchant_name])
      @user = User.create(user_params)
      if @merchant.persisted? && @user.persisted?
        @user.create_merchant_user(merchant_id: @merchant.id)
        @user.assign_merchant_role
        @user.assign_merchant_admin_role
        @user.assign_merchant_profile
      else
        error = true
      end
      if error
        raise ActiveRecord::Rollback
      end
    end

    if error
      render :new
      return
    end
    
    redirect_to admin_path, notice: 'Merchant created successfully.'
  end

  private

  def user_params
    pars = params.require(:user).permit(:username, :password, :email)
    pars[:validate_email_presence] = true
    pars[:email_promotions] = false # Merchant are not subscribed for email promotions by default
    pars
  end

end
