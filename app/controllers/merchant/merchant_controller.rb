class Merchant::MerchantController < Merchant::ActivationStepController

  append_before_filter :load_merchant

  add_breadcrumb "Търговски Профил", :merchant_edit_merchant_path

  def edit_merchant
    @merchant.agree_terms_of_use = true
  end

  def update_merchant
    if @merchant.update_attributes(merchant_params)
      on_activation_step_complete()
      if is_in_activation?
        redirect_to_activation_next_step(activation_step, method(:merchant_edit_merchant_path))
      else
        redirect_to merchant_edit_merchant_path, notice: "Успешно редактиране на информацията."
      end
    else
      render :edit_merchant
    end
  end

  def activation_step
    return Conf.merchant_activation.profile_step
  end

  private

  def sections
    [:my_menu, :update_merchant]
  end

   def merchant_params
    pars = params.require(:merchant).permit(:id,
      :description,
      :phone,
      :return_days,
      :return_instructions,
      :return_policy,
      :website,
      :agree_terms_of_use,
      :logo
    )

    return pars
  end

  def load_merchant
    @merchant = current_merchant
  end
end
