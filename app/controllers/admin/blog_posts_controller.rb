class Admin::BlogPostsController < AdminController

  def index
    @posts = BlogPost.includes(:user).order(id: :desc)
  end

  def new
    @post = BlogPost.new
  end

  def edit
    @post = BlogPost.find(params[:id])
  end

  def update
    @post = BlogPost.find(params[:id])
    
    unless @post.update_attributes(post_params)
      render :edit
      return
    end
    redirect_to admin_blog_posts_path, notice: 'Blog post edited successfully.'
  end

  def create
    @post = BlogPost.new(post_params)
    @post.user_id = current_user.id
    unless @post.save
      render :new
      return
    end
    redirect_to admin_blog_posts_path, notice: 'Blog post created successfully!'
  end

  private

  def post_params
    params.require(:blog_post).permit(
      :title, :subtitle, :text, 
      :source_title, :source_link, :main_picture,
      :main_picture_width, :main_picture_height
    )
  end


end
