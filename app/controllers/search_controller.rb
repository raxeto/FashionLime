class SearchController < ClientController

  add_breadcrumb "Търсене", :generic_search_path

  DEFAULT_ITEM_COUNT = 8

  def search
    @q = Modules::ElasticSearchHelper.handle_latin_letters(params.permit(:q)[:q])
    total_items_found = 0

    filters = []
    filters.append({ term: { visible: true } })

    @outfits = Modules::OutfitJsonBuilder.instance.outfits_partial_data(
      Outfit.es_search(@q, DEFAULT_ITEM_COUNT + 1, 0, filters),
      current_or_guest_user
    ) 
    total_items_found += @outfits.size
    if @outfits.size == DEFAULT_ITEM_COUNT + 1
      @has_more_outfits = true
      @outfits.pop
    end

    @products =  Modules::ProductJsonBuilder.instance.products_partial_data(
      Product.es_search(@q, DEFAULT_ITEM_COUNT + 1, 0, filters),
      current_profile.id
    )  
    total_items_found += @products.size
    if @products.size == DEFAULT_ITEM_COUNT + 1
      @has_more_products = true
      @products.pop
    end

    @merchants = Merchant.es_search(@q, DEFAULT_ITEM_COUNT, 0, filters).to_a
    total_items_found += @merchants.size

    @no_results = total_items_found == 0
  end

  protected

  def sections
    [:search]
  end

end
