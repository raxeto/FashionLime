desc "Change percent discount for all products of a merchant"
task :set_merchant_discount, [:merchant_id, :perc_discount] => "setup:fashionlime" do |t, args|
  products = Product.includes(:articles).where(:merchant_id => args[:merchant_id])
  products.each do |p|
    p.articles.each do |a|
      if !a.update_attributes(:perc_discount => args[:perc_discount])
        Rails.logger.error("We could not update discount for product with ID #{p.id}.")
      end
    end
    Modules::ProductJsonBuilder.instance.refresh_product_cache(p.id)
  end
  Rails.logger.info("Discounts for merchant with ID #{args[:merchant_id]} successfully updated.")
end