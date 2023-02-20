class Admin::OutfitDecorationsController < AdminController

  def index
    @decorations = OutfitDecoration.all
  end

  def new
    @decoration = OutfitDecoration.new
  end

  def edit
    @decoration = OutfitDecoration.find(params[:id])
  end

  def update
    @decoration = OutfitDecoration.find(params[:id])
    
    unless @decoration.update_attributes(outfit_decoration_params)
      render :edit
      return
    end
    redirect_to admin_outfit_decorations_path, notice: 'Outfit Decoration edited successfully.'
  end

  def create
    @decoration = OutfitDecoration.new(outfit_decoration_params)
    @decoration.order_index = OutfitDecoration.where(:category => OutfitDecoration.categories[@decoration.category]).maximum(:order_index).to_i + 1
    unless @decoration.save
      render :new
      return
    end
    redirect_to admin_outfit_decorations_path, notice: 'Outfit Decoration created successfully!'
  end

  def destroy
    if OutfitDecoration.destroy(params[:id])
      redirect_to admin_outfit_decorations_path, notice: 'Outfit Decoration destroyed successfully!'
    else 
      redirect_to admin_outfit_decorations_path, alert: 'Outfit Decoration was not destroyed!'
    end
  end

  def edit_order_index
    @category = params[:category]
    @decorations = OutfitDecoration.where(:category => @category).order(:order_index)
  end

  def update_order_index
    decoration_params = params.require(:decoration)
    error = false
    decoration_params.each do |k, v|
      d = OutfitDecoration.find_by_id(v[:id])
      if !d.update_attributes(:order_index => v[:order_index])
        error = true
      end
    end
    if !error
      redirect_to admin_outfit_decorations_path, notice: 'Outfit decorations order index updated successfully!'
    else 
      redirect_to admin_outfit_decorations_path, alert: 'Error updating outfit decorations order index.'
    end
  end

  private

  def outfit_decoration_params
    params.require(:outfit_decoration).permit(:category, :order_index, :picture)
  end


end
