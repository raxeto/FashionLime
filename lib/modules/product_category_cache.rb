module Modules
  module ProductCategoryCache

    public

    def self.invalidate
      Rails.cache.delete('product_category_cache')
      Rails.cache.delete('master_url_product_category_cache')
      Rails.cache.delete('product_category_ids_for_cache')
      Rails.cache.delete('all_category_ids_for_category_id_cache')
    end

    def self.category_ids_for(key)
      category_ids_for_key_cache[key] || Array.wrap(0)
    end

    def self.all_category_ids_for_category_id(id)
      all_category_ids_for_category_id_cache[id] || []
    end

    def self.master_category_url(product_category_id)
      product_category_master_url_cache[product_category_id]
    end

    def self.product_category_url_params(key)
      product_category_url_cache[key]
    end

    def self.product_category_master_url_cache
      Rails.cache.fetch('master_url_product_category_cache') do
        ActiveRecord::Base.connection.select_all('
          select product_categories.id, parent_level_2.url_path
          from product_categories
          join product_categories as parent_level_1 on
            parent_level_1.id = product_categories.parent_id
          join product_categories as parent_level_2 on
            parent_level_2.id = parent_level_1.parent_id
          where not exists
          (
              select id
              from product_categories as c
              where c.parent_id = product_categories.id
          )').rows.to_h
      end
    end

    def self.product_category_url_cache
      Rails.cache.fetch('product_category_cache') do
        a = ProductCategory.includes(parent: [:parent]).map do |c|
          [c.key, c.to_client_params]
        end
        a.to_h
      end
    end

    def self.category_ids_for_key_cache
      Rails.cache.fetch('product_category_ids_for_cache') do
        a = ProductCategory.includes(children: [:children]).map do |c|
          [c.key, ProductCategory.category_ids_for(c.key)]
        end
        a.to_h
      end
    end

    def self.all_category_ids_for_category_id_cache
      Rails.cache.fetch('all_category_ids_for_category_id_cache') do
        a = ProductCategory.includes(children: [:children]).map do |c|
          [c.id, c.all_ids]
        end
        a.to_h
      end
    end

  end
end
