class LocationType < ActiveRecord::Base

  def self.settlement_ids
    LocationType.where(:key => LocationType.settlement_keys).ids
  end

  def self.settlement_keys
    ['city', 'village', 'monastery', 'other_village']
  end
  
end
