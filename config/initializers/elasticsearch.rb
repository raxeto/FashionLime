config = {
  # TODO: Revise these for the production environment
  # - create separate intializers for each environment?
  host: "http://localhost:9200/",
  transport_options: {
    request: { timeout: 5 }
  },
}

if File.exists?("config/initializers/elasticsearch.yml")
  config.merge!(YAML.load_file("config/initializers/elasticsearch.yml")[Rails.env].symbolize_keys)
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
