module Modules
  module FilteredProducts

    protected

      def search_products(initial_batch_size, override_params={})
        dt_start = Time.now
        pars = filter_and_sort_product_params(override_params)
        all_words_should_match = pars[:search_phrase].present?
        count = pars[:count].try(:to_i) || initial_batch_size
        offset = pars[:offset] || 0
        terms = []

        categories = []
        if pars[:c].present?
          categories += ProductCategoryCache.category_ids_for(pars[:c])
        end
        if pars[:categories].present?
          pars[:categories].each do |c|
            categories += ProductCategoryCache.all_category_ids_for_category_id(c.to_i)
          end
        end
        if !categories.empty?
          terms.append({ 'product_category.id': categories })
        end

        trademark_ids = parse_selected_ids(pars[:trademarks])
        terms.append({ 'trade_mark.id': trademark_ids }) if trademark_ids.present?

        product_ids = parse_selected_ids(pars[:products])
        terms.append({ 'id': product_ids }) if product_ids.present?

        size_ids = parse_selected_ids(pars[:sizes])
        terms.append({ 'product_sizes.size_id': size_ids }) if size_ids.present?

        color_ids = parse_selected_ids(pars[:colors])
        terms.append({ 'product_colors.color_id': color_ids }) if color_ids.present?

        merchant_ids = parse_selected_ids(pars[:merchants])
        terms.append({ merchant_id: merchant_ids }) if merchant_ids.present?

        occasion_ids = parse_selected_ids(pars[:occasions])
        terms.append({ 'occasions.id': occasion_ids }) if occasion_ids.present?

        filters = []
        if pars[:outfit_compatible].present?
          filters.append({ term: { outfit_compatible: true } })
          outfit_merchant = [0]
          if pars[:current_merchant_id].present?
            outfit_merchant.append(pars[:current_merchant_id].to_i)
          end
          terms.append({ outfit_compatible_only_for_merchant: outfit_merchant})
        end

        terms.each do |t|
          filters.append({ terms: t })
        end

        filters.append({ term: { visible: true } })

        if pars[:price_from].present? || pars[:price_to].present?
          range_filter = {}
          filters.append({ range: { 'articles.price_with_discount': range_filter }})
          if pars[:price_from].present?
            range_filter['gte'] = pars[:price_from].to_f
          end
          if pars[:price_to].present?
            range_filter['lte'] = pars[:price_to].to_f
          end
        end

        Rails.logger.info("**** Creating the ES filters #{(Time.now - dt_start) * 1000.0} ms.")
        dt_start = Time.now
        products = Product.es_search(Modules::ElasticSearchHelper.format_search_string(pars), count,
          offset, filters, parse_product_sort_params(pars[:sort_by]), all_words_should_match, 
          Modules::ElasticSearchHelper.get_sort_by_ids(pars, "relevance"))
        Rails.logger.info("**** Whole ES search #{(Time.now - dt_start) * 1000.0} ms.")
        dt_start = Time.now

        return Modules::ProductJsonBuilder.instance.products_partial_data(products, current_profile.id)
      end

    private

      def filter_and_sort_product_params(override_params)
        params.merge(override_params).permit(:c, :price_from, :price_to, :sort_by,
            :offset, :count, :outfit_compatible, :current_merchant_id,
            :search_str, :search_phrase, sort_by_ids: [], sizes:[],
            colors:[], products: [], trademarks: [], merchants: [], occasions: [],
            categories: [])
      end

      def parse_selected_ids(selected_ids)
        selected_ids.present? ? selected_ids.select{|x| x.present?}.map{|x| x.to_i} : []
      end

      def parse_product_sort_params(sort_by)
        case sort_by
          when "price_asc"    then return [{ 'articles.price_with_discount': { order: 'asc'}}, '_score']
          when "price_desc"   then return [{ 'articles.price_with_discount': { order: 'desc'}}, '_score']
          when "created_date" then return [{ 'created_at': { order: 'desc'}}, '_score']
          when "rating"       then return [{ 'rating': { order: 'desc'}}, '_score']
          when "relevance"    then return ['_score', { 'created_at': { order: 'desc'}}]
          else return ['_score', { 'created_at': { order: 'desc'}}] # The default is by relevance
        end
      end

  end
end
