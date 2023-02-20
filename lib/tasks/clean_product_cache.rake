namespace :clean do
  desc "Cleans the old guest users that haven't made any actions"
  task :product_cache => "setup:fashionlime" do
    Product.ids.map{ |id| Modules::ProductJsonBuilder.instance.invalidate_product_cache(id) }
  end
end
