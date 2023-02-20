module Modules
  module LocationJsonBuilder
   
    def self.json_data
      Rails.cache.fetch('locations_cache') do
        Location.settlements.map { |l| { :name => l.settlement_name, :id => l.id }.to_json }
      end
    end

    def self.invalidate_cache
      Rails.cache.delete('locations_cache')
    end
  end
end

















