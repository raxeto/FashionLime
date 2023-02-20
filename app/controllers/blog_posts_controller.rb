class BlogPostsController < ClientController

  append_before_filter :load_post

  add_breadcrumb "Статия"

  def show
    @related_blog_posts = @post.related_blog_posts
  end

  private

  def load_post
    @post = BlogPost.find_by_url_path(params[:url_path])
    if @post.nil?
      # Redirects to 404
      raise ActionController::RoutingError.new("Статията не беше намерена.")
    end
  end

end
