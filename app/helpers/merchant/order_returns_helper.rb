module Merchant::OrderReturnsHelper

  def label_for_return_status(order_return)
    label_type = ""
    case order_return.status
    when "active"
      label_type = :danger
    when "waiting_return"
      label_type = :warning
    when "closed"
      label_type = :success
    end
    bootstrap_label_tag(label_type, order_return.status_i18n)
  end

  def label_for_return_detail_status(order_return_detail)
    label_type = ""
    case order_return_detail.status
    when "not_processed"
      label_type = :danger
    when "waiting_return"
      label_type = :warning
    when "returned"
      label_type = :success
    end
    bootstrap_label_tag(label_type, order_return_detail.status_i18n)
  end

end
