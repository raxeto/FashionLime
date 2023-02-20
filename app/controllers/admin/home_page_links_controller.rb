class Admin::HomePageLinksController < AdminController

  def index
    @links = HomePageLink.order(created_at: :desc)
  end

  def new
    @home_page_link = HomePageLink.new
  end

  def edit
    @home_page_link = HomePageLink.find(params[:id])
  end

  def update
    @home_page_link = HomePageLink.find(params[:id])
    
    unless @home_page_link.update_attributes(home_page_link_params)
      render :edit
      return
    end
    redirect_to admin_home_page_links_path, notice: 'Home page link edited successfully.'
  end

  def create
    @home_page_link = HomePageLink.new(home_page_link_params)
    unless @home_page_link.save
      render :new
      return
    end
    redirect_to admin_home_page_links_path, notice: 'Home page link created successfully!'
  end


  def destroy
    if HomePageLink.destroy(params[:id])
      redirect_to admin_home_page_links_path, notice: 'Home Page link destroyed successfully!'
    else 
      redirect_to admin_home_page_links_path, alert: 'Home Page link was not destroyed!'
    end

  end

  def home_page_link_params
    params.require(:home_page_link).permit(:title, :subtitle, :url_path, :position, :picture)
  end

end
