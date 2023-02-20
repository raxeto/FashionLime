class OutfitSet < ActiveRecord::Base

  # Modules
  include Modules::OpenGraphModel

  # Relations
  belongs_to :outfit_category
  belongs_to :occasion

  # Callbacks
  after_commit :open_graph_clear_cache, on: [:update]

  private

  def open_graph_clear_cache
    Modules::OpenGraph.clear_cached_pages(self)
  end

end
