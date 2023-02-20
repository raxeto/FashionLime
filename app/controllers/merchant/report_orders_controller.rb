class Merchant::ReportOrdersController < MerchantController

  include Modules::ReportLib

  add_breadcrumb "Справки поръчки", :merchant_reports_orders_path

  def orders
  end

  def generate_orders
    field_to_sql = {
      :order_number => "merchant_orders.number",
      :status => "case merchant_orders.status when 1 then 'Активна' when 2 then 'Очаква плащане' when 3 then 'Потвърдена' else '' end",
      :shipment => "merchant_shipments.name",
      :merchant_payment_type_id => "merchant_orders.merchant_payment_type_id",
      :payment_type => "payment_types.name",
      :payment_code => "case when merchant_orders.payment_code in ('#{Conf.payments.no_code}', '#{Conf.payments.epay_failed_code}') then null else merchant_orders.payment_code end",
      :date => date_part("merchant_order_details.created_at", :date),
      :month => date_part("merchant_order_details.created_at", :month),
      :quarter => date_part("merchant_order_details.created_at", :quarter),
      :year => date_part("merchant_order_details.created_at", :year),
      :day => date_part("merchant_order_details.created_at", :day),
      :order_return_number => "case when merchant_order_return_details.id is not null then merchant_orders.return_code else null end",
      :order_return_type => "case merchant_order_return_details.return_type when 1 then 'Връщане' when 2 then 'Замяна' else '' end",

      :product_name => "products.name",
      :product_id => "products.id",
      :size => "sizes.name",
      :color => "colors.name",
      :trade_mark => "trade_marks.name",

      :username => "users.username",
      :user_first_name => "orders.user_first_name",
      :user_last_name => "orders.user_last_name",
      :location => Location.settlement_name_clause,
      :email => "orders.user_email",
      :phone => "orders.user_phone",
      :issue_invoice => "case orders.issue_invoice when 1 then 'ДА' else 'НЕ' end",

      :order_total => "sum(merchant_order_details.total)",
      :order_discount => "sum(merchant_order_details.total - merchant_order_details.total_with_discount)",
      :order_total_with_discount => "sum(merchant_order_details.total_with_discount)",
      :order_shipment_total => "sum(round(merchant_order_details.qty * merchant_orders.shipment_price / merchant_order_articles_count.total_qty, 2))",
      :order_returned_total_with_discount => "sum(merchant_order_details.price_with_discount * (merchant_order_details.qty_to_return + merchant_order_details.qty_returned))",
      :order_products_count_total => "sum(merchant_order_details.qty - merchant_order_details.qty_to_return - merchant_order_details.qty_returned)",
      :order_products_count_ordered => "sum(merchant_order_details.qty)",
      :order_products_count_to_return => "sum(merchant_order_details.qty_to_return)",
      :order_products_count_returned => "sum(merchant_order_details.qty_returned)"
    }

    sumators = [
      :order_total,
      :order_discount,
      :order_total_with_discount,
      :order_shipment_total,
      :order_returned_total_with_discount,
      :order_products_count_total,
      :order_products_count_ordered,
      :order_products_count_to_return,
      :order_products_count_returned
    ]

    main_table = "merchant_order_details"
    joins = "join articles on articles.id = merchant_order_details.article_id
             join products on products.id = articles.product_id
             join sizes on sizes.id = articles.size_id
             join colors on colors.id = articles.color_id
             join merchant_orders on merchant_orders.id = merchant_order_details.merchant_order_id
             join 
              (
                select merchant_order_details.merchant_order_id, sum(merchant_order_details.qty) as total_qty
                  from merchant_order_details
                  group by merchant_order_details.merchant_order_id
              ) merchant_order_articles_count on merchant_order_articles_count.merchant_order_id = merchant_orders.id
             join orders on orders.id = merchant_orders.order_id
             join merchant_shipments on merchant_shipments.id = merchant_orders.merchant_shipment_id
             join merchant_payment_types on merchant_payment_types.id = merchant_orders.merchant_payment_type_id
             join payment_types on payment_types.id = merchant_payment_types.payment_type_id
             join addresses on addresses.owner_id = orders.id and addresses.owner_type = 'Order'
             join locations on locations.id = addresses.location_id
             join location_types on location_types.id = locations.location_type_id
             left join locations as parent_locations on parent_locations.id = locations.parent_id
             left join location_types as parent_location_types on parent_location_types.id = parent_locations.location_type_id
             left join merchant_order_return_details on merchant_order_return_details.merchant_order_detail_id = merchant_order_details.id
             left join users on users.id = orders.user_id
             left join trade_marks on trade_marks.id = products.trade_mark_id"

    filters = {
      :order_date => { :type => :between_date, :sql => "date(merchant_order_details.created_at)" },
      :order_status => { :type => :multiselect, :sql => "merchant_orders.status", :key_type => "integer" },
      :product_name => { :type => :string, :sql => field_to_sql[:product_name] },
      :product_size => { :type => :multiselect, :sql => "sizes.id", :key_type => "integer" },
      :user => { :type => :string, :sql => field_to_sql[:username] },
      :location => { :type => :string, :sql => field_to_sql[:location] }
    }

    custom_filter_clause = "merchant_orders.merchant_id = #{current_merchant.id}"

    generate_report(params, field_to_sql, sumators, main_table, joins, filters, custom_filter_clause)
    render :orders
  end

  private

  def sections
    [:reports]
  end

end
