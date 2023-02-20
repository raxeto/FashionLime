module Modules
  module MerchantActivationLib

    def is_in_activation?
      return !@activation.blank? && @activation.casecmp("true") == 0
    end

    def load_activation
      @activation = params[:activation]
    end

    def activation_step_completed?(step)
      case step
      when Conf.merchant_activation.profile_step
        return current_merchant.valid?
      when Conf.merchant_activation.payments_step
        return current_merchant.available_merchant_payment_types.exists?
      when Conf.merchant_activation.shipments_step
        return current_merchant.merchant_shipments.exists?
      when Conf.merchant_activation.size_chart_step
        return current_merchant.size_charts.exists?
      else
        return false
      end
    end

    def activation_not_completed_message(step)
      case step
      when Conf.merchant_activation.profile_step
        return ''
      when Conf.merchant_activation.payments_step
        return 'Моля, добавете поне един начин на плащане, за да завършите тази стъпка.'
      when Conf.merchant_activation.shipments_step
        return 'Моля, въведете поне един тип доставка, за да завършите тази стъпка.'
      when Conf.merchant_activation.size_chart_step
        return 'Моля, дефинирайте поне една таблица с размери за типовете продукти, които ще продавате.'
      else
        return false
      end
    end

    def redirect_to_first_activation_step
      redirect_to_activation_step(first_activation_step)
    end

    def redirect_to_activation_next_step(step, not_completed_url)
      if activation_step_completed?(step)
        next_step = step + 1
        redirect_to_activation_step(next_step)
      else
        flash[:alert] = activation_not_completed_message(step)
        redirect_to not_completed_url.call(:activation => "true")
      end
    end

    def on_activation_step_complete
      if all_steps_completed?
        activate_merchant()
      end
    end

    def activate_merchant
      merchant = current_merchant
      if merchant.not_completed?
        merchant.update_attributes(status: Merchant.statuses[:active])
      end
    end

    def step_description(step)
      case step
      when Conf.merchant_activation.profile_step
        return 'Моля, въведете малко информация за фирмата, която представяте. Може да качите и лого.'
      when Conf.merchant_activation.payments_step
        return 'Моля, изберете поне един начин на плащане, който клиентите Ви ще използват, когато правят поръчки към Вас.'
      when Conf.merchant_activation.shipments_step
        return 'Моля, добавете поне един тип доставка, който клиентите Ви да избират, когато правят поръчки към Вас.'
      when Conf.merchant_activation.size_chart_step
        return 'Моля, дефинирайте таблица с размери за типовете продукти, които ще продавате.'
      else
        return ''
      end
    end

    private

    def all_steps_completed?
      (1..Conf.merchant_activation.steps_count).each do |i|
        return false if !activation_step_completed?(i)
      end
      true
    end

    def redirect_to_activation_step(step)
      case step
      when Conf.merchant_activation.profile_step
        redirect_to merchant_edit_merchant_path(:activation => "true")
        return
      when Conf.merchant_activation.payments_step
        redirect_to merchant_payment_types_activation_path(:activation => "true")
        return
      when Conf.merchant_activation.shipments_step
        redirect_to merchant_shipments_path(:activation => "true")
        return
      when Conf.merchant_activation.size_chart_step
        redirect_to new_merchant_size_chart_path(:activation => "true")
        return
      when Conf.merchant_activation.steps_count + 1
        merchant = current_merchant
        if merchant.active?
          flash[:notice] = "Профилът Ви беше активиран успешно."
          redirect_to merchant_root_path
        else
          flash[:alert] = "Възникна проблем при активиране на профила. Моля опитайте отново."
          redirect_to merchant_root_path
        end
        return
      end
      redirect_to merchant_root_path
    end

    def first_activation_step
      (1..Conf.merchant_activation.steps_count).each do |i|
        return i if !activation_step_completed?(i)
      end
      return Conf.merchant_activation.steps_count + 1
    end

  end
end
