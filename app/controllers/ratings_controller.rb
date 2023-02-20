class RatingsController < ClientController

  append_before_filter :authenticate_as_non_guest, :load_model

  def increase
    Rating.increase(@model, current_user)
    render json: { status: true }
  end

  def decrease
    Rating.decrease(@model, current_user)
    render json: { status: true }
  end

  def invalidate
    Rating.invalidate(@model, current_user)
    render json: { status: true }
  end

  private 

  def load_model
    @model = nil
    id = params[:id]
    case params[:model_type].try(:upcase).try(:strip) || ''
    when "PRODUCT"
      @model = Product.find_by_id(id)
    when "OUTFIT"
      @model = Outfit.find_by_id(id)
    when "MERCHANT"
      @model = Merchant.find_by_id(id)
    end
  end
end
