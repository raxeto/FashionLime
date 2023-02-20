class FavoritesController < ClientController

  append_before_filter :authenticate_as_non_guest

  add_breadcrumb "Харесвания", :favorites_index_path

  def index
    items = current_user.profile.ratings.includes(:owner).where('rating > 0').order(created_at: :desc).map(&:owner)

    @no_results = items.size == 0

    outfits = []
    products = []
    items.each do |i|
      if i.class == Product
        products << i
      elsif i.class == Outfit
        outfits << i
      end
    end

    @outfits = Modules::OutfitJsonBuilder.instance.outfits_partial_data(
      outfits,
      current_or_guest_user
    ) 

    @products =  Modules::ProductJsonBuilder.instance.products_partial_data(
      products,
      current_profile.id
    ) 
  end

  protected

  def sections
    [:my_menu, :my_favorites]
  end

end
