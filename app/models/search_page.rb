class SearchPage < ActiveRecord::Base

  # Modules
  include Modules::OpenGraphModel

  # Callbacks
  before_save  :update_url_path
  after_commit :open_graph_clear_cache, on: [:update]

  # Attributes
  enum category: { product: 1, outfit: 2 }

  private

  def update_url_path
    url = Modules::StringLib.unicode_downcase(title).gsub(' ', '-')
    self.url_path = url
    true
  end

  def open_graph_clear_cache
    Modules::OpenGraph.clear_cached_pages(self)
  end

end
