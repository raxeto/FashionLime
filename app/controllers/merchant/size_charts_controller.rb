class Merchant::SizeChartsController < Merchant::ActivationStepController

  append_before_filter :load_size_chart_preload, only: [:edit, :update]
  append_before_filter :load_size_chart,         only: [:destroy, :destroy_item]

  add_breadcrumb "Таблици с размери",  :merchant_size_charts_path
  add_breadcrumb "Новa таблица",       :new_merchant_size_chart_path, only: [:new, :create]
  add_breadcrumb "Промяна на таблица", :edit_merchant_size_chart_path, only: [:edit, :update]

  def index
    @size_charts = current_merchant.size_charts.includes(:size_category)
  end

  def new
    @size_chart = SizeChart.new
    @size_chart.name = params[:name]
    @size_chart.note = params[:note]
    size_category = SizeCategory.find_by_id(params[:size_category])
    unless size_category.nil?
      @size_chart.size_category = size_category
      order_index = 1
      size_category.sizes.each do |s|
        size_category.size_descriptors.each do |d|
          @size_chart.size_chart_descriptors.build({
            :size => s,
            :size_descriptor_id => d.id,
            :order_index => order_index
          })
          order_index = order_index + 1
        end
      end
    end
  end

  def create
    @size_chart = current_merchant.size_charts.create(size_chart_params)
    unless @size_chart.persisted?
      render :new
      return
    end
    on_activation_step_complete()
    if is_in_activation?
      redirect_to_activation_next_step(activation_step, method(:new_merchant_size_chart_path))
    else
      redirect_to edit_merchant_size_chart_path(@size_chart), notice: 'Таблицата беше създадена.'
    end
  end

  def edit
  end

  def update
    if @size_chart.update_attributes(size_chart_params)
      redirect_to edit_merchant_size_chart_path(@size_chart), notice: "Успешно редактиране."
    else
      render :edit
    end
  end

  def destroy
    begin
      @size_chart.destroy!()
      redirect_to merchant_size_charts_path, notice: 'Успешно изтриване.'
    rescue ActiveRecord::ActiveRecordError
      redirect_to merchant_size_charts_path, alert: @size_chart.errors.full_messages
    end
  end

  def destroy_item
    pars = params.permit(:id, :size_id)
    success = true
    ActiveRecord::Base.transaction do
      begin
        @size_chart.size_chart_descriptors.where(:size_id => pars[:size_id]).each do |d|
          d.destroy!
        end
      rescue ActiveRecord::ActiveRecordError
        success = false
      end
      if !success
        raise ActiveRecord::Rollback
      end
    end

    if success
      render json: { status: true }
    else
      render json: { status: false, error: 'Неуспешно изтриване.' }
    end
  end

  private

  def size_chart_params
    params.require(:size_chart).permit(
      :name, :size_category_id, :note,
      size_chart_descriptors_attributes: [:id, :size_id, :size_descriptor_id, :value_from, :value_to, :order_index] )
  end

  def load_size_chart_preload
    @size_chart = current_merchant.size_charts.includes(size_chart_descriptors: [:size]).find_by_id(params[:id])
    check_if_null
  end

  def load_size_chart
    @size_chart = current_merchant.size_charts.find_by_id(params[:id])
    check_if_null
  end

  def check_if_null
    if @size_chart.nil?
      redirect_to merchant_size_charts_path, alert: 'Тази таблица с размери не принадлежи на Вашия акаунт и не можете да я манипулирате!'
    end
  end

  def activation_step
    return Conf.merchant_activation.size_chart_step
  end

  def sections
    [:settings]
  end

end
