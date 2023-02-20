class Admin::OpenGraphTagsController < AdminController

  def index
    @tags = OpenGraphTag.all
  end

  def new
    @tag = OpenGraphTag.new
  end

  def edit
    @tag = OpenGraphTag.find(params[:id])
  end

  def update
    @tag = OpenGraphTag.find(params[:id])
    
    unless @tag.update_attributes(open_graph_tag_params)
      render :edit
      return
    end
    redirect_to admin_open_graph_tags_path, notice: 'Open graph tag edited successfully.'
  end

  def create
    @tag = OpenGraphTag.new(open_graph_tag_params)
    unless @tag.save
      render :new
      return
    end
    redirect_to admin_open_graph_tags_path, notice: 'Open graph tag created successfully!'
  end

  def destroy
    if OpenGraphTag.destroy(params[:id])
      redirect_to admin_open_graph_tags_path, notice: 'Open graph tag destroyed successfully!'
    else 
      redirect_to admin_open_graph_tags_path, alert: 'Open graph tag was not destroyed!'
    end
  end

  private

  def open_graph_tag_params
    params.require(:open_graph_tag).permit(:page_link, :title, :description, :picture_width, :picture_height, :picture)
  end


end
