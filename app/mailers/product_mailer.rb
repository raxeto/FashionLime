class ProductMailer < ApplicationMailer

  def merchant_min_available_qty(article)
    emails = article.product.merchant.active_emails
    if emails.blank?
      return
    end
    subject = I18n.t('mailers.product.merchant_min_available_qty.subject', :article_name => article.full_name)
    @article = article
    mail(to: emails, subject: subject)  
  end

end
