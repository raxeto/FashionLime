module Modules
  module FilteredOutfits

    protected

      def search_outfits(initial_batch_size, override_params={})
        pars = filter_and_sort_outfit_params(override_params)
        all_words_should_match = pars[:search_phrase].present?
        count = pars[:count].try(:to_i) || initial_batch_size
        offset = pars[:offset] || 0

        filters = []
        filters.append({ term: { visible: true } })
        filters.append({ term: { profile_id: pars[:profile_id].to_i }}) if pars[:profile_id].present?
        filters.append({ term: { outfit_category_id: pars[:c].to_i }}) if pars[:c].present?

        terms = []
        merchant_ids = parse_selected_ids(pars[:merchants])
        terms.append({ merchant_id: merchant_ids }) if merchant_ids.present?

        trademark_ids = parse_selected_ids(pars[:trademarks])
        terms.append({ trade_mark_ids: trademark_ids }) if trademark_ids.present?

        outfit_ids = parse_selected_ids(pars[:outfits])
        terms.append({ id: outfit_ids }) if outfit_ids.present?

        occasion_ids = parse_selected_ids(pars[:occasions])
        terms.append({ 'outfit_occasions.occasion_id': occasion_ids }) if occasion_ids.present?

        product_category_ids = parse_selected_ids(pars[:categories])
        product_category_ids = ProductCategory.all_uniq_ids(product_category_ids)
        terms.append({ product_categories: product_category_ids }) if product_category_ids.present?

        product_ids = parse_selected_ids(pars[:products])
        terms.append({ product_ids: product_ids }) if product_ids.present?

        terms.each do |t|
          filters.append({ terms: t })
        end

        if pars[:price_from].present?
          filters.append({ range: { 'max_price': {'gte': pars[:price_from].to_f } }})
        end

        if pars[:price_to].present?
          filters.append({ range: { 'min_price': {'lte': pars[:price_to].to_f } }})
        end

        outfits = Outfit.es_search(Modules::ElasticSearchHelper.format_search_string(pars), count,
          offset, filters, parse_outfit_sort_params(pars[:sort_by]), all_words_should_match,
          Modules::ElasticSearchHelper.get_sort_by_ids(pars, "relevance"))

        return Modules::OutfitJsonBuilder.instance.outfits_partial_data(outfits, current_or_guest_user)
      end

    private

      def filter_and_sort_outfit_params(override_params)
        params.merge(override_params).permit(:sort_by, :offset, :count, :price_from, :price_to, :c,
          :profile_id, :search_str, :search_phrase, merchants: [], occasions: [], categories: [],
          products: [], trademarks: [], outfits: [], sort_by_ids: [])
      end

      def parse_selected_ids(selected_ids)
        selected_ids.present? ? selected_ids.select{|x| x.present?}.map{|x| x.to_i} : []
      end

      def parse_outfit_sort_params(sort_by)
        case sort_by
          when "created_date" then return [{ 'created_at': { order: 'desc'}}, '_score']
          when "rating"       then return [{ 'rating': { order: 'desc'}}, '_score']
          when "relevance"    then return ['_score', { 'created_at': { order: 'desc'}}]
          else return ['_score', { 'created_at': { order: 'desc'}}]
        end
      end

  end
end
