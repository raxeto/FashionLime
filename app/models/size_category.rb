class SizeCategory < ActiveRecord::Base

    # Relations
    has_many  :sizes, -> { order(:order_index) } 

    has_many  :size_category_descriptors
    has_many  :size_descriptors, -> { order(:order_index) }, :through => :size_category_descriptors

    has_many  :size_category_product_categories

    # Scopes
    scope :for_product_category, -> (id) {
      category = ProductCategory.find_by id: id
      if category.nil?
        SizeCategory.all
      else
        joins(:size_category_product_categories).where(:size_category_product_categories => 
          {:product_category_id => Modules::ProductCategoryCache.category_ids_for(category.key)}).distinct
      end  
    }

    # Used to filter No size option
    scope :meaningful, -> {
      includes(:sizes).where.not(:sizes => {:key => 'standart'})
    }
    
end
