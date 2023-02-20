class Admin::UsersController < AdminController

  def index
    @users = User.all
  end

  def avatars
    @from_date = params[:from_date].try(:to_date)
    @to_date = params[:to_date].try(:to_date)
    if @from_date.present? && @to_date.present?
      @users = User.where(:avatar_updated_at => @from_date.beginning_of_day..@to_date.end_of_day)
    end
  end

  def destroy_avatar
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render json: { status: false, error: "Потребителя не е намерен" }
      return
    end

    if @user.update_attributes(:avatar => nil)
      render json: { status: true }
    else
      render json: { status: false, error: @user.errors.full_messages }
    end
  end

end
