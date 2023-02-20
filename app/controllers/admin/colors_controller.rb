class Admin::ColorsController < AdminController

  def index
    @colors = Color.all
  end

  def new
      @color = Color.new
  end

  def edit
    @color = Color.find(params[:id])
  end

  def update
    @color = Color.find(params[:id])
    
    unless @color.update_attributes(color_params)
      render :edit
      return
    end
    redirect_to admin_colors_path, notice: 'Color edited successfully.'
    end

  def create
    @color = Color.new(color_params)
    unless @color.save
      render :new
      return
    end
    redirect_to admin_colors_path, notice: 'Color created successfully!'
  end

  def destroy
    if Color.destroy(params[:id])
      redirect_to admin_colors_path, notice: 'Color destroyed successfully!'
    else 
      redirect_to admin_colors_path, alert: 'Color was not destroyed!'
    end

  end

  private

  def color_params
    params.require(:color).permit(:name, :code, :key, :order_index, :picture)
  end


end
