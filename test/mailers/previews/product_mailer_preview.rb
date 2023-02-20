# Preview all emails at http://localhost:3000/rails/mailers/product_mailer
class ProductMailerPreview < ActionMailer::Preview

   def merchant_min_available_qty
    article = Product.where.not(:min_available_qty => nil).first.articles.first
    ProductMailer.merchant_min_available_qty(article)
  end

end
