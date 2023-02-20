class OrderMailer < ApplicationMailer

  def user_new(order)
    subject = I18n.t('mailers.order.user_new.subject')
    email = order.user_email
    if email.blank?
      return
    end
    @order = order
    mail(to: email, subject: subject)
  end

  def merchant_new(merchant_order)
    subject = I18n.t('mailers.order.merchant_new.subject')
    emails = merchant_order.merchant.active_emails
    @merchant_order = merchant_order
    mail(to: emails, subject: subject)
  end

  def user_confirmed(merchant_order)
    subject = I18n.t('mailers.order.user_confirmed.subject')
    email = merchant_order.order.user_email
    if email.blank?
      return
    end
    @merchant_order = merchant_order
    mail(to: email, subject: subject)
  end

  def user_canceled(merchant_order)
    subject = I18n.t('mailers.order.user_canceled.subject')
    email = merchant_order.order.user_email
    if email.blank?
      return
    end
    @merchant_order = merchant_order
    mail(to: email, subject: subject)
  end

  def merchant_return(merchant_order_return)
    emails = merchant_order_return.merchant_order.merchant.active_emails
    @order_return = merchant_order_return
    @order_return_type = format_return_type(merchant_order_return)
    subject = I18n.t('mailers.order.merchant_return.subject', :return_type => @order_return_type)
    mail(to: emails, subject: subject)
  end

  def user_return(merchant_order_return)
    email = merchant_order_return.user_email
    @order_return = merchant_order_return
    @order_return_type = format_return_type(merchant_order_return)
    @merchant = @order_return.merchant_order.merchant
    subject = I18n.t('mailers.order.user_return.subject', :return_type => @order_return_type)
    mail(to: email, subject: subject)
  end

  def format_return_type(merchant_order_return)
    order_return_count = merchant_order_return.merchant_order_return_details.where(:return_type => MerchantOrderReturnDetail.return_types[:return]).count
    order_exchange_count = merchant_order_return.merchant_order_return_details.where(:return_type => MerchantOrderReturnDetail.return_types[:exchange]).count
    if order_return_count > 0 && order_exchange_count > 0
      return "връщане и замяна"
    elsif order_return_count > 0
      return "връщане"
    else
      return "замяна"
    end
  end

end
