class Merchant::ProductCollectionsController < MerchantController

  append_before_filter :load_collection, only: [:edit, :update, :destroy]

  add_breadcrumb "Моите колекции", :merchant_product_collections_path
  add_breadcrumb "Новa колекция", :merchant_product_collections_path, only: [:new]
  add_breadcrumb "Промяна на колекция", :merchant_product_collections_path, only: [:edit, :update, :destroy]


  def index
    @collections = current_merchant.product_collections.order("created_at DESC").includes(:season, :products).all
  end

  def new
    @collection = ProductCollection.new
    # Current year default
    @collection.year = Time.zone.today.year
  end

  def create
    @collection = current_merchant.product_collections.create(collection_params)
    unless @collection.valid?
      render :new
      return
    end
    redirect_to edit_merchant_product_collection_path(@collection), notice: 'Колекцията беше създадена.'
  end

  def edit
  end

  def update
    if @collection.update_attributes(collection_params)
      redirect_to edit_merchant_product_collection_path(@collection), notice: "Успешно редактиране."
    else
      render :edit
    end
  end

  def destroy
    begin
      @collection.destroy!()
      flash[:notice] = 'Колекцията беше изтрита.'
      render json: { status: true }
    rescue ActiveRecord::ActiveRecordError
        message = ""
        @collection.errors.each do |attr, msg|
          message += msg
        end
        flash[:alert] = message
        render json: { status: false, error: message }
    end
  end



  protected

  def collection_params
    params.require(:product_collection).permit(
      :name,
      :description,
      :season_id,
      :year,
      :picture
      )
  end

  def load_collection
    @collection = current_merchant.product_collections.find_by_id(params[:id])
    if @collection.nil?
      redirect_to merchant_product_collections_path, alert: 'Тази колекция не принадлежи на Вашия акаунт и не можете да я манипулирате!'
    end
  end



  def sections
    [:products]
  end

end
