class Admin::MerchantProductApiMappingsController < AdminController
  def index
    @mappings = MerchantProductApiMapping.order(id: :desc).page(params[:page] || 1).per(20)
  end

  def new
    @mapping = MerchantProductApiMapping.new
  end

  def edit
    @mapping = MerchantProductApiMapping.find(params[:id])
  end

  def update
    @mapping = MerchantProductApiMapping.find(params[:id])
    begin
      if @mapping.update_attributes(mapping_params)
        redirect_to admin_merchant_product_api_mappings_path, notice: 'Mapping edited successfully.'
        return
      end
    rescue
      @mapping.errors.add(:base, 'Could not update this mapping. Are you sure it\'s not a duplicate one?')
    end
    render :edit
  end

  def create
    @mapping = MerchantProductApiMapping.new(mapping_params)
    begin
      if @mapping.save
        redirect_to admin_merchant_product_api_mappings_path, notice: 'Mapping created successfully!'
        return
      end
    rescue
      @mapping.errors.add(:base, 'Could not create this mapping. Are you sure it\'s not a duplicate one?')
    end
    render :new
  end

  def destroy
    if MerchantProductApiMapping.destroy(params[:id])
      redirect_to admin_merchant_product_api_mappings_path, notice: 'Mapping destroyed successfully!'
    else
      redirect_to admin_merchant_product_api_mappings_path, alert: 'Mapping was not destroyed!'
    end
  end

  private

  def mapping_params
    params.require(:merchant_product_api_mapping).permit(:merchant_id, :object_type, :object_id, :input_value)
  end

end
