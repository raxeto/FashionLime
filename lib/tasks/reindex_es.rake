desc "Reindexes all Elasticsearch models"
task :reindex_es => "setup:fashionlime" do
  t = Time.now
  Modules::ElasticSearchHelper.setup_elastic_search_indexes(Outfit)
  Modules::ElasticSearchHelper.setup_elastic_search_indexes(Product)
  Modules::ElasticSearchHelper.setup_elastic_search_indexes(Merchant)
  Rails.logger.info("Done in #{(Time.now - t).seconds} seconds")
end
