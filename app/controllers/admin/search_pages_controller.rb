class Admin::SearchPagesController < AdminController

  def index
    @search_pages = SearchPage.order(id: :desc)
  end

  def new
    @search_page = SearchPage.new
  end

  def edit
    @search_page = SearchPage.find(params[:id])
  end

  def update
    @search_page = SearchPage.find(params[:id])
    
    unless @search_page.update_attributes(search_page_params)
      render :edit
      return
    end
    redirect_to admin_search_pages_path, notice: 'Page edited successfully.'
    end

  def create
    @search_page = SearchPage.new(search_page_params)
    unless @search_page.save
      render :new
      return
    end
    redirect_to admin_search_pages_path, notice: 'Page created successfully!'
  end

  private

  def search_page_params
    params.require(:search_page).permit(:title, :description, :meta_title, :meta_description, :og_image, :category)
  end


end
