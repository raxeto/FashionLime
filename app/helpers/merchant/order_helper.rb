module Merchant::OrderHelper

  def label_for_order_status(order)
    label_type = ""
    case order.status
    when "active"
      label_type = :danger
    when "waiting_payment"
      label_type = :warning
    when "confirmed"
      label_type = :success
    end
    bootstrap_label_tag(label_type, order.status_i18n)
  end

end
