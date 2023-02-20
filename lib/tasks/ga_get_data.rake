namespace :ga do
  desc "Gets Google Analytics data for 24 hours and imports it in the database.
    Pass current date as argument. Example: rake ga:get_data[2016-01-01]"
  task :get_data, [:curr_date] => "setup:fashionlime" do |t, args|

    if args[:curr_date].blank?
      Rails.logger.error 'Wrong number of arguments! Pass current date (format Year-Month-Day eg. 2016-01-16)!'
      next
    end

    require 'google/api_client'

    client  = Google::APIClient.new(:application_name => 'FashionLime', :application_version => '1')

    client.authorization = Signet::OAuth2::Client.new(
      :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
      :audience             => 'https://accounts.google.com/o/oauth2/token',
      :scope                => 'https://www.googleapis.com/auth/analytics.readonly',
      :issuer               => Conf.google_analytics.service_account_email,
      :signing_key          => Google::APIClient::PKCS12.load_key(Conf.google_analytics.key_file, 'notasecret')
    ).tap { |auth| auth.fetch_access_token! }

    api_method = client.discovered_api('analytics','v3').data.ga.get

    # Queries documentation
    # https://developers.google.com/apis-explorer/#p/analytics/v3/analytics.data.ga.get
    # Dimensions and metrics explorer - https://developers.google.com/analytics/devguides/reporting/core/dimsmets
    # Dimensions can be maximum 7 - https://developers.google.com/analytics/devguides/reporting/core/v2/gdataReferenceDataFeed
    # Filters reference - https://developers.google.com/analytics/devguides/reporting/core/v3/reference#filters

    product_starts = []
    ProductCategory.children_from_key('outfit').each do |c|
      product_starts << "/#{c.url_path}/"
    end

    outfit_starts = []
    OutfitCategory.all.each do |c|
      outfit_starts << "/vizii/#{c.url_path}/"
    end

    merchant_profile_start = '/m/'

    filters = ""
    (product_starts + outfit_starts + [merchant_profile_start]).each do |f|
      filters << "," if filters.length > 0
      filters << "ga:pagePath=~^#{f}"
    end

    end_date = Date.parse(args[:curr_date])
    start_date = end_date - 1.day

    result = client.execute(:api_method => api_method, :parameters => {
      'ids'         => Conf.google_analytics.view_id,
      'start-date'  => start_date.to_s('%Y-%m-%d'),
      'end-date'    => end_date.to_s('%Y-%m-%d'),
      'dimensions'  => 'ga:pagePath,ga:previousPagePath,ga:userType,ga:deviceCategory,ga:city,ga:dimension1,ga:date',
      'metrics'     => 'ga:pageviews,ga:uniquePageviews,ga:timeOnPage',
      'filters'     => filters,
      'max-results' => 10000 # TODO fetch on parts https://developers.google.com/analytics/devguides/reporting/core/v2/gdataReferenceDataFeed#maxResults
    })

    if result.error?
       Rails.logger.error("GA API returned an error: #{result.error_message}")
       next
    end

    next if result.data.rows.size == 0

    if result.data.rows.size >= 10000 
      Rails.logger.error("GA API has more than the maximum 10000 records. Implement fetching!")
      next
    end

    col_indexes = {}
    result.data.columnHeaders.each_with_index do |colHeader, index|
      col_indexes[colHeader.name] = index
    end

    new_records = Array.new(result.data.rows.size)

    result.data.rows.each_with_index do |row, index|
      page_path = row[col_indexes["ga:pagePath"]].squeeze("/")
      model = nil

      # Merchant Profile Pages
      if page_path.start_with?(merchant_profile_start)
        merchant_url_path = page_path[(merchant_profile_start.length)..-1]
        if merchant_url_path.present?
          merchant_url_path = merchant_url_path[0..((merchant_url_path.index('/') || 0) - 1)]
          model = Merchant.find_by url_path: merchant_url_path
        end
      else
        # Product Pages
        product_starts.each do |ps|
          if page_path.start_with?(ps)
            product_id = get_id_from_url(ps, page_path)
            if product_id > 0
              model = Product.find_by_id(product_id)
            end
          end
        end
        # Outfit Pages
        outfit_starts.each do |os|
          if page_path.start_with?(os)
            outfit_id = get_id_from_url(os, page_path)
            if outfit_id > 0
              model = Outfit.find_by_id(outfit_id)
              if model.present?
                 if !model.user.merchant? # We are interested only in outfits created by merchants
                  model = nil
                 end
              end
            end
          end
        end
      end

      user_id = row[col_indexes["ga:dimension1"]]
      user = User.find_by_id(user_id)
      if !model.nil?
        rec = {
          related_model: model,
          user: user,
          view_date: DateTime.strptime(row[col_indexes["ga:date"]], '%Y%m%d'),
          previous_page: row[col_indexes["ga:previousPagePath"]],
          user_type: row[col_indexes["ga:userType"]],
          device_category: row[col_indexes["ga:deviceCategory"]],
          city: row[col_indexes["ga:city"]],
          page_views: row[col_indexes["ga:pageviews"]],
          unique_page_views: row[col_indexes["ga:uniquePageviews"]],
          time_on_page: row[col_indexes["ga:timeOnPage"]]
        }
        new_records[index] = rec
      end
    end

    success = true
    begin
      GaPageView.create!(new_records.select { |r| !r.nil?})
    rescue ActiveRecord::RecordInvalid
      success = false
    end

    if success
      Rails.logger.info("Run for #{args[:curr_date]} was a success")
    else
      Rails.logger.error("Run for #{args[:curr_date]} failed!")
    end
    success
  end

  def get_id_from_url(prefix, url)
    model_url = url[prefix.length..-1]
    if model_url.present?
      id_dash = model_url.rindex('-')
      if id_dash.present?
        id = model_url[(id_dash + 1)..-1].to_i
        return id
      end
    end
    0
  end

end
