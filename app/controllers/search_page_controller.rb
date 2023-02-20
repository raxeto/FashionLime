class SearchPageController < ClientController

  append_before_filter :load_product_category,  only: [:product_page]
  append_before_filter :load_outfit_category,   only: [:outfit_page]
  append_before_filter :load_search_properties, only: [:product_page, :outfit_page]

  include Modules::FilteredProducts
  include Modules::FilteredOutfits

  def product_page
    @section = :products
    add_breadcrumb "Продукти", :products_path
    add_breadcrumb @search_page.title
    @products = search_products(Conf.search.initial_item_count, {})
  end

  def product_page_load_more
    @products = search_products(Conf.search.initial_item_count, {})
    render json: [@products.map(&:html_safe)]
  end

  def outfit_page
    @section = :outfits
    add_breadcrumb "Визии", :outfits_path
    add_breadcrumb @search_page.title
    @outfits = search_outfits(Conf.search.initial_item_count, {})
  end

  def outfit_page_load_more
    @outfits = search_outfits(Conf.search.initial_item_count, {})
    render json: [@outfits.map(&:html_safe)]
  end

protected

  def sections
    [@section]
  end

private

  def load_product_category
    @category = SearchPage.categories[:product]
  end

  def load_outfit_category
    @category = SearchPage.categories[:outfit]
  end

  def load_search_properties
    @search_phrase = params[:search_phrase]
    @search_page = SearchPage.where(:url_path => @search_phrase, :category => @category).first
    if @search_page.nil?
      if @category == SearchPage.categories[:product]
        redirect_to products_path(:search_str => @search_phrase), :status => 301
      else
        redirect_to outfits_path(:search_str => @search_phrase), :status => 301
      end        
    end
  end

end
