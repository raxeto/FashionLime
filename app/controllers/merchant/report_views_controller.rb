class Merchant::ReportViewsController < MerchantController

  include Modules::ReportLib

  append_before_filter :redirect_coming_soon

  add_breadcrumb "Справки разглеждания", :merchant_reports_views_path

  def generate_views
    field_to_sql = {
      :date => date_part("ga_page_views.view_date", :date),
      :month => date_part("ga_page_views.view_date", :month),
      :quarter => date_part("ga_page_views.view_date", :quarter),
      :year => date_part("ga_page_views.view_date", :year),
      :day => date_part("ga_page_views.view_date", :day),

      :model_name => "case ga_page_views.related_model_type
                        when 'Product' then products.name
                        when 'Outfit' then outfits.name
                        when 'Merchant' then merchants.name
                      end",
      :model_type => "ga_page_views.related_model_type",

      :username => "users.username",
      :city => "ga_page_views.city",
      :user_type => "ga_page_views.user_type",
      :device_category => "ga_page_views.device_category",
      :previous_page => "ga_page_views.previous_page",

      :page_views => "sum(ga_page_views.page_views)",
      :unique_page_views => "sum(ga_page_views.unique_page_views)",
      :time_on_page => "sum(ga_page_views.time_on_page)",
      :orders_total => "sum(product_merchant_orders.total_with_discount)"
    }

    sumators = [
      :page_views,
      :unique_page_views,
      :time_on_page,
      :orders_total
    ]

    # orders_total is removed from sumators, because it can be pointed out correctly
    # if one product has views on one day but is ordered on another day "left join" is not correct
    # we need to use full outer join, which My SQL does not support.
    # left join
    #          (
    #           select articles.product_id, date(merchant_order_details.created_at) as order_date, sum(total_with_discount) as total_with_discount
    #           from merchant_order_details
    #           join merchant_orders on merchant_orders.id = merchant_order_details.merchant_order_id
    #           join articles on articles.id = merchant_order_details.article_id
    #           where merchant_orders.merchant_id = #{current_merchant.id}
    #           group by articles.product_id, date(merchant_order_details.created_at)
    #          ) as product_merchant_orders on product_merchant_orders.product_id = products.id
    #                   and product_merchant_orders.order_date = ga_page_views.view_date

    main_table = "ga_page_views"
    joins = "left join users on users.id = ga_page_views.user_id
             left join products on products.id = ga_page_views.related_model_id
              and ga_page_views.related_model_type = 'Product'
             left join outfits on outfits.id = ga_page_views.related_model_id
              and ga_page_views.related_model_type = 'Outfit'
             left join merchants on merchants.id = ga_page_views.related_model_id
              and ga_page_views.related_model_type = 'Merchant'
             "

    filters = {
      :view_date => { :type => :between_date, :sql => "ga_page_views.view_date" },
      :model_type => { :type => :multiselect, :sql => field_to_sql[:model_type], :key_type => "string" },
      :model => { :type => :string, :sql => field_to_sql[:model_name] },
      :user_type => { :type => :multiselect, :sql => field_to_sql[:user_type], :key_type => "string" },
      :user => { :type => :string, :sql => field_to_sql[:username] },
      :city => { :type => :string, :sql => field_to_sql[:city] }
    }

    custom_filter_clause = "(
         (ga_page_views.related_model_type = 'Product' and products.merchant_id = #{current_merchant.id}) or
         (ga_page_views.related_model_type = 'Outfit' and outfits.profile_id = #{current_merchant.profile.id}) or
         (ga_page_views.related_model_type = 'Merchant' and merchants.id = #{current_merchant.id})
        )"

    generate_report(params, field_to_sql, sumators, main_table, joins, filters, custom_filter_clause)
    render :views
  end

  private

  def sections
    [:reports]
  end

  def redirect_coming_soon
    if Rails.env.production?
      redirect_to merchant_root_path, :notice => "Справката ще бъде налична съвсем скоро."
    end
  end

end
