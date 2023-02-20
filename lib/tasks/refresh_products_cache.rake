require 'net/imap'

desc "Refreshes the cache for a tenth of the products"
task :refresh_products_cache => "setup:fashionlime" do
  t = Time.now + 59.seconds

  # We want to refresh all products in 10 invocations, thus we need to know which
  # invocation we are in atm so that we know which products to update.
  start_index = (t.min / 6).to_i
  all_products_count = Product.count
  batch_size = ((all_products_count + 9) / 10).to_i
  Rails.logger.info("Working with #{all_products_count} products. Batch size: #{batch_size}. Index: #{start_index}")
  Product.order(:id).offset(start_index * batch_size).limit(batch_size).collection_display.each do |product|
    Modules::ProductJsonBuilder.instance.refresh_product_cache_for_product(product)
  end
  Rails.logger.info("Done refreshing the products cache")
end
