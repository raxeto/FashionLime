# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview

  def user_new
    order = MerchantOrder.find(15).order
    OrderMailer.user_new(order)
  end

  def merchant_new
    merchant_order = MerchantOrder.find(7)
    OrderMailer.merchant_new(merchant_order)
  end

  def user_confirmed
    merchant_order = MerchantOrder.find(27)
    OrderMailer.user_confirmed(merchant_order)
  end

  def merchant_return
    order_return = MerchantOrderReturn.find(1)
    OrderMailer.merchant_return(order_return)
  end

  def user_canceled
    order = MerchantOrder.find(26)
    OrderMailer.user_canceled(order)
  end

  def user_return
    order_return = MerchantOrderReturn.find(1)
    OrderMailer.user_return(order_return)
  end

end
