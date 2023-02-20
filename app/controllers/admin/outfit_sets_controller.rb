class Admin::OutfitSetsController < AdminController

  def index
    @outfit_sets = OutfitSet.order(:outfit_category_id, :occasion_id)
  end

  def new
    @outfit_set = OutfitSet.new
  end

  def edit
    @outfit_set = OutfitSet.find(params[:id])
  end

  def update
    @outfit_set = OutfitSet.find(params[:id])
    
    unless @outfit_set.update_attributes(outfit_set_params)
      render :edit
      return
    end
    redirect_to admin_outfit_sets_path, notice: 'Outfit set edited successfully.'
    end

  def create
    @outfit_set = OutfitSet.new(outfit_set_params)
    unless @outfit_set.save
      render :new
      return
    end
    redirect_to admin_outfit_sets_path, notice: 'Outfit set created successfully!'
  end

  private

  def outfit_set_params
    params.require(:outfit_set).permit(:outfit_category_id, :occasion_id, :description, :meta_title, :meta_description, :og_image)
  end

end
