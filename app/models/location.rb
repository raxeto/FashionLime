class Location < ActiveRecord::Base

  # Relations
  belongs_to :parent, class_name: "Location"
  has_many   :children, class_name: "Location", foreign_key: "parent_id"

  belongs_to :location_type

  # Scopes
  scope :settlements, -> {
    includes(:location_type, parent: [:location_type]).
    where(:location_type_id => LocationType.settlement_ids).
    order("case when location_type_id = #{LocationType.find_by_key('city').id} then 1 else 2 end, name") # First show cities then other villages
  }

  # Callbacks
  after_commit :invalidate_locations_cache

  def settlement_name
    if LocationType.settlement_keys.include?(location_type.key)
      "#{location_type.key == 'city' || location_type.key == 'village' ? location_type.short_name + ' ' : ''}#{name}, #{parent.location_type.short_name} #{parent.name}"
    else
      name
    end
  end

  def self.settlement_name_clause
    city_village_ids = LocationType.where(:key => ['city', 'village']).ids.join(',')
    "concat( 
    case when locations.location_type_id in (#{city_village_ids}) then concat(location_types.short_name, ' ') else '' end,
    locations.name,
        case when parent_location_types.id is not null then concat(
      ', ',
      parent_location_types.short_name, 
      ' ',
      parent_locations.name
        )
        else '' end
    )"
  end

  def contains_location?(location_to_find)
    return true if self.id == location_to_find

    children.each do |child_location|
      res = child_location.contains_location?(location_to_find)
      return true if res
    end

    return false
  end

  def invalidate_locations_cache
    Modules::LocationJsonBuilder.invalidate_cache
  end

end
