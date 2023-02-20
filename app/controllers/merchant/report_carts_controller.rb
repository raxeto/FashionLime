class Merchant::ReportCartsController < MerchantController

  include Modules::ReportLib

  add_breadcrumb "Справка колички", :merchant_reports_carts_path

  def carts
  end

  def generate_carts
    field_to_sql = {
      :cart_id => "details.cart_id",
      :status => "case when details.cart_id is null then 'Изтрит' else 'Съществуващ' end",
      :date => date_part("details.created_at", :date),
      :month => date_part("details.created_at", :month),
      :quarter => date_part("details.created_at", :quarter),
      :year => date_part("details.created_at", :year),
      :day => date_part("details.created_at", :day),
      :updated_at => date_part("details.updated_at", :date),

      :product_name => "products.name",
      :product_id => "products.id",
      :size => "sizes.name",
      :color => "colors.name",
      :trade_mark => "trade_marks.name",

      :username => "users.username",
     
      :cart_total => "sum(details.total)",
      :cart_discount => "sum(details.total - details.total_with_discount)",
      :cart_total_with_discount => "sum(details.total_with_discount)",
      :cart_products_count => "sum(details.qty)"
    }

    sumators = [
      :cart_total,
      :cart_discount,
      :cart_total_with_discount,
      :cart_products_count
    ]

    main_table = "
                (
                  select cart_id, carts.user_id, article_id, price, perc_discount, price_with_discount, qty, total, total_with_discount, cart_details.created_at, cart_details.updated_at
                    from cart_details
                    join carts on carts.id = cart_details.cart_id
                    union all
                    select null as cart_id, user_id,article_id, price, perc_discount, price_with_discount, qty, round(price * qty, 2) as total, round(price_with_discount * qty, 2) as total_with_discount, added_at as created_at, created_at as updated_at
                    from cart_deleted_details
                ) details"
    joins = "join articles on articles.id = details.article_id
             join products on products.id = articles.product_id
             join sizes on sizes.id = articles.size_id
             join colors on colors.id = articles.color_id
             left join users on users.id = details.user_id
             left join trade_marks on trade_marks.id = products.trade_mark_id"

    filters = {
      :added_date => { :type => :between_date, :sql => "date(details.created_at)" },
      :cart_status => { :type => :multiselect, :sql => "case when details.cart_id is null then 'deleted' else 'existing' end", :key_type => "string" },
      :product_name => { :type => :string, :sql => field_to_sql[:product_name] },
      :product_category => { :type => :multiselect, :sql => "products.product_category_id" },
      :product_size => { :type => :multiselect, :sql => "sizes.id" },
      :user => { :type => :string, :sql => field_to_sql[:username] }
    }

    custom_filter_clause = "products.merchant_id = #{current_merchant.id}"

    generate_report(params, field_to_sql, sumators, main_table, joins, filters, custom_filter_clause)
    render :carts
  end

  private

  def sections
    [:reports]
  end

end
