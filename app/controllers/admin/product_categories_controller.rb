class Admin::ProductCategoriesController < AdminController

  def index
    @product_categories = ProductCategory.order(:order_index)
  end

  def new
    @product_category = ProductCategory.new
  end

  def edit
    @product_category = ProductCategory.find(params[:id])
  end

  def update
    @product_category = ProductCategory.find(params[:id])
    
    unless @product_category.update_attributes(category_params)
      render :edit
      return
    end
    redirect_to admin_product_categories_path, notice: 'Category edited successfully.'
    end

  def create
    @product_category = ProductCategory.new(category_params)
    unless @product_category.save
      render :new
      return
    end
    redirect_to admin_product_categories_path, notice: 'Category created successfully!'
  end

  private

  def category_params
    params.require(:product_category).permit(:name, :description, :key, :parent_id, :url_path, :meta_title, :meta_description, :og_image, :order_index)
  end


end
