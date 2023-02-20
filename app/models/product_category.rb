require 'set'

class ProductCategory < ActiveRecord::Base

  # Modules
  include Modules::OpenGraphModel

  # Attributes
  enum status: { visible: 1, hidden: 2 }

  # Relations
  belongs_to :parent, class_name: "ProductCategory"
  has_many   :children, -> { order(:order_index) }, class_name: "ProductCategory", foreign_key: "parent_id"

  # Scopes
  scope :children_from_key, -> (key) {
    joins(:parent).where(:parents_product_categories => {:key => key}).order(:order_index)
  }

  scope :visible_children_from_key, -> (key) {
    joins(:parent).where(:product_categories => {:status => ProductCategory.statuses[:visible]}, :parents_product_categories => {:key => key}).order(:order_index)
  }

  scope :flat_list, -> {
    includes(:parent, :children).where(:parent_id => ProductCategory.where(:key => ['women']).pluck(:id)).order(:order_index)
  }

  # Callbacks
  after_commit :invalidate_product_category_cache
  after_commit :open_graph_clear_cache, on: [:update]

  public

  def name_with_parent
    "#{name} [#{Modules::StringLib.unicode_downcase(parent.try(:name) || '')}]"
  end

  def to_client_params
    if key == 'men' || key == 'women'
      { :category => url_path }
    elsif parent.try(:key) == 'men' || parent.try(:key) == 'women'
      { :category => parent.url_path, :subcategory_or_product => url_path }
    elsif !parent.nil? && !parent.parent.nil?
      { :category => parent.parent.url_path, :subcategory_or_product => url_path }
    else
      {}
    end
  end

  def self.category_ids_for(search_key)
    category = ProductCategory.find_by key: search_key
    if category.nil?
      return Array.wrap(0)
    end
    category.all_ids
  end

  def all_ids
    [id] + all_children_ids
  end

  def all_children_ids
    if children.size == 0
      return []
    end
    ret = child_ids
    children.each do |child|
      ret += child.all_children_ids
    end
    ret
  end

  def self.all_uniq_ids(id_list)
    s = Set.new
    id_list.each do |id|
      s.merge(ProductCategory.find_by(id: id).try(:all_ids) || [])
    end
    return s.to_a
  end

  def deep_find_child_by_url_path(url)
    url = Modules::StringLib.unicode_downcase(url)
    children.each do |c|
      if !c.url_path.nil? && Modules::StringLib.unicode_downcase(c.url_path) == url
        return c
      end
      gc = c.deep_find_child_by_url_path(url)
      unless gc.nil?
        return gc
      end
    end
    nil
  end

  def visible_children
    children.where(:status => ProductCategory.statuses[:visible])
  end

  def update_status
    has_products = Product.visible.where(:product_category_id => id).size > 0
    if has_products
      if hidden?
        update_attributes(:status => ProductCategory.statuses[:visible])
      end
    else
      if visible?
        update_attributes(:status => ProductCategory.statuses[:hidden])
      end
    end
  end

  private

  def invalidate_product_category_cache
    Modules::ProductCategoryCache.invalidate
  end

  def open_graph_clear_cache
    Modules::OpenGraph.clear_cached_pages(self)
  end


end
