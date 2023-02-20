class HomeController < ClientController

  def index
    variant = HomePageVariant.current
    if variant.present?
      home_page_links_ids = variant.object_ids('HomePageLink')
      @home_page_links = HomePageLink.where(id: home_page_links_ids)
      @home_page_links = @home_page_links.sort_by { |l| home_page_links_ids.index(l.id) }

      @main_home_page_link = nil
      @home_page_links.each do |l|
        if l.position == "main"
          @main_home_page_link = l
        end
      end
      if @main_home_page_link.present?
        @home_page_links.delete(@main_home_page_link)        
      end

      collection_ids = variant.object_ids('ProductCollection')
      @product_collections = ProductCollection.collection_display.where(id: collection_ids)
      @product_collections = @product_collections.sort_by { |c| collection_ids.index(c.id) }
      
      outfit_ids = variant.object_ids('Outfit')
      @outfits = Modules::OutfitJsonBuilder.instance.outfits_partial_data(
        Outfit.where(id: outfit_ids).visible.sort_by { |o| outfit_ids.index(o.id) },
        current_or_guest_user
      ) 

      merchant_ids = variant.object_ids('Merchant')
      @merchants = Merchant.collection_display.where(id: merchant_ids)
      @merchants = @merchants.sort_by { |m| merchant_ids.index(m.id) }

      product_ids = variant.object_ids('Product')
      @products = Modules::ProductJsonBuilder.instance.products_partial_data(
        Product.where(id: product_ids).visible.sort_by { |p| product_ids.index(p.id) },
        current_profile.id
      ) 
    end
    render :layout => "home"
  end

  protected

  def sections
    [:home]
  end

end
