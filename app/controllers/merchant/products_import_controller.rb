class Merchant::ProductsImportController < MerchantController

  require 'roo'

  include Modules::SpreadsheetLib
  include Modules::CurrencyLib

  append_before_filter :load_merchant, only: [:preview, :confirm]

  add_breadcrumb "Моите продукти", :merchant_products_path
  add_breadcrumb "Импорт", :merchant_import_products_path

  def index
  end

  def preview
    file = params[:import_file]
    spreadsheet = open_spreadsheet_from_uploaded_file(file)
    header_hash = get_spreadsheet_columns_hash(spreadsheet)
    @products = []
    (2..spreadsheet.last_row).each do |i|
      r = spreadsheet.row(i)
      p = Product.new
      
      errors =  {}

      if has_defined(header_hash, r, "name")
        p.name = r[header_hash["name"]]
      end

      if has_defined(header_hash, r, "description")
        p.description = r[header_hash["description"]]
      end

      if has_defined(header_hash, r, "collection")
        collection = @merchant.product_collections.find_by_id(r[header_hash["collection"]])
        if collection.nil?
          errors["product_collection_id"] = "несъществуващо ID на колекция"
        else
          p.product_collection = collection
        end
      end

      if has_defined(header_hash, r, "trademark")
        trade_mark = TradeMark.find_by key: r[header_hash["trademark"]]
        if trade_mark.nil?
          errors["trade_mark_id"] = "несъществуващ ключ на търговска марка"
        else
          p.trade_mark = trade_mark
        end
      end

      if has_defined(header_hash, r, "category")
        category = ProductCategory.find_by key: r[header_hash["category"]]
        if category.nil?
          errors["product_category_id"] = "несъществуваща категория"
        elsif category.children.size > 0
          errors["product_category_id"] = "главна категория не може да бъде асоциирана към продукт"
        else
          p.product_category = category
        end
      end

      if has_defined(header_hash, r, "status")
        status = r[header_hash["status"]]
        if Product.statuses[status].nil?
          errors["status"] = "несъществуващ статус"
        else
          p.status = status
        end
      end

      if has_defined(header_hash, r, "sizes")
        size_keys = r[header_hash["sizes"]].split(',').collect { |x| x.strip }.uniq
        sizes = Size.where(:key => size_keys)
        if size_keys.size != sizes.size
          errors["size_ids"] = "несъществуващ размер"
        else
          p.sizes = sizes
        end
      end

      if has_defined(header_hash, r, "colors")
        color_keys = r[header_hash["colors"]].split(',').collect { |x| x.strip }.uniq
        colors = Color.where(:key => color_keys)
        if color_keys.size != colors.size
          errors["color_ids"] = "несъществуващ цвят"
        else
          p.colors = colors
        end
      end

      if has_defined(header_hash, r, "occasions")
        occasion_keys = r[header_hash["occasions"]].split(',').collect { |x| x.strip }.uniq
        occasions = Occasion.where(:key => occasion_keys)
        if occasion_keys.size != occasions.size
          errors["occasion_ids"] = "несъществуващ повод"
        else
          p.occasions = occasions
        end
      end

      if has_defined(header_hash, r, "price")
        p.imp_price = r[header_hash["price"]]
        if p.imp_price.is_a? Numeric
          p.imp_price = p.imp_price.round(2)
        end
      else
        errors["imp_price"] = "трябва да бъде дефинирана"
      end

      if has_defined(header_hash, r, "discountperc")
        p.imp_perc_discount = r[header_hash["discountperc"]]
        if p.imp_perc_discount.is_a? Numeric
          p.imp_perc_discount = p.imp_perc_discount.round(2)
        end
      else
        p.imp_perc_discount = 0.0
      end
      
      if (p.imp_price.is_a? Numeric) && (p.imp_perc_discount.is_a? Numeric)
        p.imp_price_with_discount = calc_price_with_discount(p.imp_price || 0.0, p.imp_perc_discount || 0.0)
      end

      if has_defined(header_hash, r, "qty")
        p.imp_qty = r[header_hash["qty"]]
      end

      if has_defined(header_hash, r, "emailminqty")
        p.min_available_qty = r[header_hash["emailminqty"]]
      end

      # Call validations
      p.valid?

      # Add errors afterwards
      errors.each_pair do |k, v|
        p.errors.add(k, v)
      end

      @products.push(p)
    end
    render :index
  end

  def confirm
    success = true
    ActiveRecord::Base.transaction do
      params[:products].each do |p|
        begin
          pars = JSON.parse(p)
          product = current_merchant.products.create({
            :name => pars["name"],
            :description => pars["description"],
            :product_collection_id => @merchant.product_collections.find_by_id(pars["product_collection_id"]).try(:id) || '',
            :product_category_id => pars["product_category_id"],
            :trade_mark_id => pars["trade_mark_id"],
            :status => pars["status"],
            :size_ids => pars["size_ids"],
            :color_ids => pars["color_ids"],
            :user_id => current_user.id,
            :occasion_ids => pars["occasion_ids"],
            :base_price => pars["imp_price"] || 0.0,
            :min_available_qty => pars["min_available_qty"]
          })

          if product.persisted?
            product.articles.each do |a|
              atttrib = {
                    :perc_discount => pars["imp_perc_discount"] || 0.0
                    }
              if !pars["imp_qty"].blank? && pars["imp_qty"].to_i != 0
                atttrib[:article_quantities_attributes] = [ { :qty => pars["imp_qty"], :active => 1 } ]
              end
              success = a.update_attributes(atttrib)
              break unless success
            end
          else
            success = false
          end

        rescue ActiveRecord::ActiveRecordError
          success = false
        end

        unless success
          raise ActiveRecord::Rollback
        end
      end
    end

    if success
      redirect_to merchant_products_path, notice: 'Продуктите бяха импортирани успешно.'
    else
      redirect_to merchant_products_path, alert: 'Възникна грешка при импортирането на продуктите.'
    end
  end

  def sections
    [:products]
  end

  private 

  def load_merchant
    @merchant = current_merchant
  end

  def has_defined(header_hash, r, col)
    unless header_hash[col].nil?
      val = r[header_hash[col]]
      unless val.blank?
        return true
      end
    end
    return false
  end

end
