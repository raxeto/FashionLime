require 'openssl'

desc "Refreshes the products for a given merchant"
task :refresh_merchant_products, [:task_id] => "setup:fashionlime" do |t, args|
  include Modules::CurrencyLib

  task = MerchantProductsSyncTask.find_by_id(args[:task_id])
  if task.nil?
    Rails.logger.error("Merchant Products Sync Task with ID #{args[:task_id]} not found.")
    next # Effect of return because task is actually a block and return can't be used
  end

  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  Rails.logger.info("Scraping merchant id: #{task.merchant_id} from #{task.scrape_url} with #{task.parser_class_name}")
  merchant = Merchant.find(task.merchant_id)
  parser = "Modules::MerchantProductSyncParsers::#{task.parser_class_name}".constantize.new

  lock_merchant_products(task)

  if update_products(merchant, task.scrape_url, parser)
    Rails.logger.info("All done.")
  else
    Rails.logger.error("Job failed! Sending email to admins.")
    AdminMailer.new_problem_occurred_email("There was a problem while updating products for merchant #{merchant.name}. Check the logs for errors.").deliver_now
  end

  unlock_merchant_products(task)

  Modules::ElasticSearchHelper.setup_elastic_search_indexes(Product)
end

def lock_merchant_products(task)
  success = true
  begin
    success = task.update_attributes(:in_progress => 1)
  rescue StandardError => e
    success = false
  end
  if !success
    AdminMailer.new_problem_occurred_email("There was an error while locking merchant products for import. Task id is #{task.id}.").deliver_now
  end
end

def unlock_merchant_products(task)
  success = true
  begin
    success = task.update_attributes(:in_progress => 0)
  rescue StandardError => e
    success = false
  end
  if !success
    AdminMailer.new_problem_occurred_email("There was an error while unlocking merchant products for import. Task id is #{task.id}.").deliver_now
  end
end

def build_sku_map(merchant_products)
  sku_map = {}
  merchant_products.each do |p|
    p.articles.each do |a|
      if a.sku.present?
        sku_map[a.sku] = p
      end
    end
  end
  return sku_map
end

def build_product_by_name_map(merchant_products)
  product_by_name_map = {}
  merchant_products.each do |p|
    product_by_name_map[p.name] = p
  end
  return product_by_name_map
end

def match_existing_product(merchant, sku_map, product_by_name_map, product_hash, articles_hash, parser)
  articles_hash.each do |a|
    if a.key?(:sku) && a[:sku].present? && sku_map.key?(a[:sku])
      return sku_map[a[:sku]]
    end
  end

  if parser.check_matching_by_name
    # We failed to match the product using its articles' SKUs. Try to match it by name.
    if product_by_name_map.key?(product_hash[:name])
      return product_by_name_map[product_hash[:name]]
    end
  end

  return nil
end

def check_product_hash(product_hash)
  if !check_articles_uniqueness(product_hash[:articles])
    Rails.logger.error("Articles are not unique for product with name #{product_hash[:name]}. Articles hash is #{product_hash[:articles]}.")
    return false
  end
  return true
end

def check_product_pictures(product_hash)
  if !check_picture_presence(product_hash[:product_pictures])
    Rails.logger.error("Product with name #{product_hash[:name]} does not have pictures.")
    return false
  end
  return true
end

def check_articles_uniqueness(articles_hash)
  var_hash = {}
  articles_hash.each do |a|
    pair = [a[:size_id], a[:color_id]]
    if var_hash.key?(pair)
      return false
    end
    var_hash[pair] = pair
  end
  return true
end

def check_picture_presence(product_pictures_hash)
  if product_pictures_hash.nil? || product_pictures_hash.size == 0
    return false
  end
  product_pictures_hash.each do |pp|
    if pp[:source_url].present?
      return true
    end
  end
  return false
end

def is_available(articles_hash)
  articles_hash.each do |a|
    if a[:qty].to_f >= Conf.math.QTY_EPSILON
      return true
    end
  end
  return false
end

def init_hash(product_hash, articles_hash, user_id)
  product_hash[:size_ids] = articles_hash.map {|a| a[:size_id].to_i }.uniq
  product_hash[:color_ids] = articles_hash.map {|a| a[:color_id].to_i }.uniq

  # This should be updated afterwards so does not matter
  product_hash[:base_price] = articles_hash.length > 0 ? articles_hash.first[:price] : 0.0

  product_hash[:user_id] = user_id
end

def update_product_pictures(product, product_pictures_hash)
  source_url_map = {}
  product.product_pictures.each do |pp|
    source_url_map[pp.source_url] = pp
  end

  current_pps = {}
  success = true
  begin

    product_pictures_hash.each do |pph|
      source_url = pph[:source_url]
      # It's a new picture - add it
      if !source_url_map.key?(source_url)
        pph[:product_id] = product.id
        file = nil
        if pph.delete(:get_with_open_uri) == true # Returns deleted record value
          file = open(URI.parse(source_url))
          pph[:picture] = file
        else
          pph[:picture] = create_uri(source_url)
        end
        new_picture = ProductPicture.create(pph)
        if file.present?
          file.close
        end
        if !new_picture.persisted?
          Rails.logger.error("Error creating new product picture. Picture hash is #{pph}. Errors are: #{new_picture.errors.full_messages}.")
          success = false
        end
        source_url_map[source_url] = new_picture # Put it here in order not to be created if repeated
      else
        product_picture = source_url_map[source_url]
        product_picture.assign_attributes({ :color_id => pph[:color_id] })
        if product_picture.changed?
          if !product_picture.save
            success = false
            Rails.logger.error("Failed to update product picture. Product picture ID #{product_picture.id}. Picture hash is #{pph}. Errors are: #{product_picture.errors.full_messages}.")
          end
        end
      end
      current_pps[source_url] = source_url
    end

    if success
      product.product_pictures.each do |pp|
        if !current_pps.key?(pp.source_url) && pp.outfit_compatible == 0 # Admins can upload additional images for outfits 
          begin
            pp.destroy!()
          rescue ActiveRecord::RecordNotDestroyed
            Rails.logger.info("The picture with id #{pp.id} could not be destroyed because it is used by other database objects.")
          end
        end
      end
    end

  rescue StandardError => e
    success = false
    Rails.logger.error("Error updating product pictures for product with ID: #{product.id}. Error is #{e}. Hash is: #{product_pictures_hash}. Backtrace: #{e.backtrace.join('\n')}")
  end
  success
end

def create_uri(url)
  begin
    URI.parse(url)
  rescue
    # Sometimes the URLs include non ascii characters. Then we fail to parse them.
    URI.parse(URI.encode(url))
  end
end

def update_articles(product, articles_hash, sync_discounts)
  success = true
  error = ""
  begin
    need_save = false
    articles_hash.each do |a|
      a[:price]  = a[:price].to_f.round(2)
      article = product.articles.select {|art| art.size_id ==  a[:size_id] && art.color_id == a[:color_id]}.first
      to_assign = {
        :price => a[:price],
        :sku => a[:sku]
      }

      if sync_discounts
        if a.key?(:perc_discount)
          a[:perc_discount] = a[:perc_discount].to_f.round(2)
        end
        if a.key?(:price_with_discount)
          a[:perc_discount] = calc_perc_discount(a[:price].to_f, a[:price_with_discount].to_f)
          a.delete(:price_with_discount)
        end
        to_assign[:perc_discount] = a[:perc_discount]
      end
      article.assign_attributes(to_assign)
      if article.changed?
        need_save = true
      end
    end
    if need_save
      if !product.save
        success = false
        Rails.logger.error("Failed to update product articles. Product ID #{product.id}. Articles hash data is #{articles_hash}. Errors are #{product.errors.full_messages}.")
      end
    end
  rescue StandardError => e
    Rails.logger.error("Failed to update product articles. Product ID #{product.id}. Articles hash data is #{articles_hash}. Error is #{e}.")
    success = false
  end
  return success
end

def update_quantities(product, articles_hash)
  curr_articles = {}
  success = true
  articles_hash.each do |a|
    article = product.articles.select {|art| art.size_id ==  a[:size_id] && art.color_id == a[:color_id]}.first
    if article.present?
      success &= article.update_available_quantity(a[:qty])
      curr_articles[article.id] = article.id
    else
      success = false
      Rails.logger.error("Failed to find article. Product ID: #{product.id}, Color ID: #{a[:color_id]}, Size ID: #{a[:size_id]} while updating quantities.")
    end
  end
  # Missing articles deactivate quantities
  missing_art_attr = []
  product.articles.each do |a|
    if !curr_articles.key?(a.id) && a.available_qty >= Conf.math.QTY_EPSILON
      success &= a.update_available_quantity(0)
    end
  end
  return success
end

def update_product(product, product_hash)
  # Add the new variants. For the missing ones the qty will be set to 0.
  product_hash[:color_ids] = (product.color_ids + product_hash[:color_ids]).uniq
  product_hash[:size_ids] = (product.size_ids + product_hash[:size_ids]).uniq

  relation_changed = ((product.color_ids.sort !=  product_hash[:color_ids].sort) ||
                      (product.size_ids.sort !=  product_hash[:size_ids].sort) ||
                      (product.occasion_ids.sort !=  (product_hash[:occasion_ids]  || []).sort))

  # Change back to normal if it has availability (otherwise it will not be updated)
  product_hash[:status] = Product.statuses[:normal]
  success = true
  begin
    product.assign_attributes(product_hash)
    if !product.changed? && !relation_changed
      return true
    end
    success = product.save
    if !success
      Rails.logger.error("Failed to update product ID #{product.id}. Hash data is #{product_hash}. Errors are: #{product.errors.full_messages}.")
    end
  rescue StandardError => e
    success = false
    Rails.logger.error("Failed to update product ID #{product.id}. Hash data is #{product_hash}. Error is #{e}.")
  end
  return success
end

def create_product(merchant, product_hash)
  p = merchant.products.create(product_hash)
  if p.persisted?
    return p
  end
  Rails.logger.error("Failed to create product. Hash data is #{product_hash}. Errors are: #{p.errors.full_messages}.")
  return nil
end

def delete_product(p)
  success = true
  if !p.hidden?
    Rails.logger.info("Hiding product ID #{p.id} #{p.name}")
    if !p.update_attributes(:status => Product.statuses[:hidden])
      Rails.logger.error("We couldn't hide the product with ID #{p.id}. Errors are: #{p.errors.full_messages}.")
      success = false
    end
  end
  success
end

def update_products(merchant, scrape_url, parser)
  begin
    response = parser.fetch_content(scrape_url)
    errors = 0
    product_hashes = parser.process(merchant, response)
    if parser.error_occurred
      errors += 1
    end
    if product_hashes.size == 0
      Rails.logger.error("There is no products in the feed for merchant #{merchant.name}.")
      return false
    end
    merchant_products = merchant.products.includes(:product_pictures, :sizes, :colors, articles: [:article_quantities])
    sku_map = build_sku_map(merchant_products)
    product_by_name_map = build_product_by_name_map(merchant_products)

    current_products = {}
    user_id = User.find_by_username(Conf.product.import_username).id

    products_added = 0
    product_hashes.each do |ph|
      if !check_product_hash(ph)
        errors += 1
        next
      end
      if !check_product_pictures(ph)
        # No need to notify all admins for products without pictures.
        next
      end

      if !is_available(ph[:articles])
        # Does not import out of stock products. If they are presented already the script will delete (or hide) them at the end
        Rails.logger.info("Product with name #{ph[:name]} will not be imported because it doesn't have available qty.")
        next
      end
      product_pictures_hash = ph[:product_pictures]
      articles_hash = ph[:articles]

      # articles_hash.each do |a|
      #   puts("csv: #{ph[:name]},#{a[:sku]},#{a[:price]},#{a[:their_color]},#{a[:qty]}")
      # end

      ph.delete(:product_pictures)
      ph.delete(:articles)

      init_hash(ph, articles_hash, user_id)

      p = match_existing_product(merchant, sku_map, product_by_name_map, ph, articles_hash, parser)
      if p.present?
        ### Update ###
        unless update_product(p, ph)
          # Unlike with the creation of a product, if we fail to update it we use the old version.
          errors += 1
        end

        current_products[p.id] = p
      else
        ### Create ###
        p = create_product(merchant, ph)
        if p.present?
          current_products[p.id] = p
        else
          errors += 1
        end
      end

      if p.present?
        if !update_product_pictures(p, product_pictures_hash)
          errors += 1
        end
        if !update_articles(p, articles_hash, parser.sync_discounts)
          errors += 1
        end
        if !update_quantities(p, articles_hash)
          errors += 1
        end
        products_added += 1
      end
    end

    merchant_products.each do |p|
      unless current_products.key?(p.id)
        if !delete_product(p)
          errors += 1
        end
      end
    end

  rescue StandardError => e
    Rails.logger.error("We crashed while trying to sync the products for #{merchant.name} - error: #{e}, backtrace #{e.backtrace.join('\n')}")
    return false
  end
  Rails.logger.info("Done. #{products_added} products for merchant #{merchant.name} scraped. #{errors} errors encountered.")
  return errors == 0
end
