module Modules
  module ElasticSearchHelper

      @@settings = {
        index: {
          number_of_shards: 1,
          analysis: {
            filter: {
                bulgarian_synonym: {
                    type: 'synonym',
                    # To add more, here is the logic for stemming http://members.unine.ch/jacques.savoy/Papers/BUIR.pdf
                    synonyms: ['пъстр,шарн,цветн']
                },
                bulgarian_stop: {
                  'type':       'stop',
                  'stopwords':  '_bulgarian_'
                },
                # For words that we want to exclude from stemming.
                # bulgarian_keywords: {
                #   'type':       'keyword_marker',
                #   'keywords':   []
                # },
                bulgarian_stemmer: {
                  'type':       'stemmer',
                  'language':   'bulgarian'
                }
            },
            analyzer: {
              fashionlime_bg: {
                tokenizer:  'standard',
                filter: [
                  'lowercase',
                  'bulgarian_stop',
                  # 'bulgarian_keywords',
                  'bulgarian_stemmer',
                  'bulgarian_synonym'
                ]
              }
            },
          }
        }
      }.freeze

      @@en_to_bg_mapping = {
        "a" => "а",
        "b" => "б",
        "c" => "ц",
        "ch" => "ч",
        "d" => "д",
        "e" => "е",
        "f" => "ф",
        "g" => "г",
        "h" => "х",
        "i" => "и",
        "j" => "ж",
        "ju" => "ю",
        "k" => "к",
        "l" => "л",
        "m" => "м",
        "n" => "н",
        "o" => "о",
        "p" => "п",
        "q" => "я",
        "r" => "р",
        "s" => "с",
        "sh" => "ш",
        "sht" => "щ",
        "t" => "т",
        "u" => "у",
        "v" => "в",
        "w" => "в",
        "x" => "х",
        "y" => "ъ",
        "z" => "з",
      }.freeze

      # NB: if importing becomes too slow, we can write a custom import method using this:
      # http://www.codinginthecrease.com/news_article/show/409843?referrer_id=

      def self.setup_elastic_search_indexes(model_class)
        Rails.logger.info("Reindexing all #{model_class} instances.")
        # Delete the previous index in Elasticsearch
        model_class.__elasticsearch__.client.indices.delete index: model_class.index_name rescue nil

        # Create the new index with the new mapping
        model_class.__elasticsearch__.client.indices.create \
          index: model_class.index_name,
          body: { settings: @@settings.to_hash, mappings: model_class.mappings.to_hash }

        # Index all records from the DB to Elasticsearch
        # NB: import all and filter later
        model_class.import
      end

      def self.format_query(query = '', count = nil, offset = nil,
          filters = [], sort_by = nil, query_fields = nil, all_words_should_match = false,
          sort_by_ids = nil)
        sort_by = {_score: 'desc'} unless sort_by.present?
        es_query = {}
        es_query[:size] = count.to_i unless count.nil?
        es_query[:from] = offset.to_i unless offset.nil?
        es_query[:sort] = sort_by

        query_dict = {}
        if query.present?
          query_dict = {
            multi_match: {
              query: query,
              fields: query_fields,
              type: 'best_fields',

              # So that we can account for typos and partially spelled terms
              fuzziness: 'AUTO',

              # If the analyzer used removes all tokens in a query, return all records
              zero_terms_query: 'all',

              # If some of the terms are too common, show only results with the rarer ones
              # cutoff_frequency?
            }
          }

          if all_words_should_match
            query_dict[:multi_match][:type] = 'cross_fields'
            query_dict[:multi_match][:operator] = 'and'
          end
        end

        if filters.present?
          es_query[:query] = { filtered: {
              filter: {
                'and': filters
              }
            }
          }

          if query_dict.present?
            es_query[:query][:filtered][:query] = query_dict
          end
        elsif query_dict.present?
          es_query[:query] = query_dict
        end

        if sort_by_ids.present?
          es_query[:query] = {
            function_score: {
              boost_mode: 'replace',
              query: es_query[:query],
              script_score: {
                # script: "count = ids.size(); id = org.elasticsearch.index.mapper.Uid.idFromUid(doc['_uid'].value); for (i = 0; i < count; i++) { if (id == ids[i]) { return count - i; }}"
                script: {
                  file: "sort_by_ids",
                  lang: "groovy",
                  params: {
                    ids: sort_by_ids,
                  },
                }
              }
            }
          }
          es_query[:sort] = {_score: 'desc'}
        end

        # Return only the ID of the records. We are reloading them from the DB either way.
        es_query[:fields] = ['id']

        return es_query
      end

      def self.format_search_string(params)
        phrase = handle_latin_letters(params[:search_phrase].to_s)
        str = handle_latin_letters(params[:search_str].to_s)
        "#{phrase} #{str}".strip.presence || phrase.strip.presence || str.strip.presence
      end

      def self.get_sort_by_ids(params, default_sort)
        sort_by_ids = nil
        # Sort by ids only if sort param is missing or is the default one
        if params[:sort_by_ids].present? && (!params[:sort_by].present? || params[:sort_by] == default_sort)
          sort_by_ids = params[:sort_by_ids]
        end
        return sort_by_ids
      end

      def self.handle_latin_letters(search_str)
        res = search_str
        search_str = search_str.downcase
        if /[a-z]/.match(search_str)
          # Translate the letters to the Bulgrian equivalent and concat the two
          # strings as we will be trying to match both of them

          # First substitute the longer letter combinations
          transformed_str = search_str.gsub('sht', 'щ')
          transformed_str = transformed_str.gsub('sh', 'ш')
          transformed_str = transformed_str.gsub('ch', 'ч')
          transformed_str = transformed_str.gsub('ju', 'ю')
          transformed_str = transformed_str.gsub('iu', 'ю')

          # Now all the others
          transformed_str = transformed_str.gsub(/[a-z]/, @@en_to_bg_mapping)
          res = "#{res} #{transformed_str}"
        end
        res
      end

      def self.filter_by_score(records, es_res, options)
        dt_start = Time.now
        min_score = options[:min_score] || 0
        percent_max = options[:percent_max] || 0
        max_score = 0
        scores = {}

        # Extract the score for each ID.
        es_res.results.each do |r|
          scores[r._id.to_i] = r._score
          max_score = [min_score, r._score].max
        end

        # Filter the records by score using the options
        bad_ids = []
        scores.each do |id, score|
          if score < min_score
            bad_ids << id
          end
          if max_score * percent_max / 100.0 > score
            bad_ids << id
          end
        end

        if bad_ids.present?
          records = records.where('id NOT IN (?)', bad_ids)
        end
        Rails.logger.info("**** ES filter by score #{(Time.now - dt_start) * 1000.0} ms.")
        return records
      end

  end
end
