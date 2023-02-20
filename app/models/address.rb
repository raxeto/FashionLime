class Address < ActiveRecord::Base

  # Attributes
  attr_accessor :location_suggestion

  # Relations
  belongs_to :location
  belongs_to :owner, polymorphic: true

  # Validations
  validates_presence_of :location_suggestion, if: Proc.new { |a| a.owner_type == "Order" }
  validates_presence_of :location
  validates_presence_of :description

  # Callbacks
  before_validation :create_location_from_suggestion

  def text
    "#{location.try(:settlement_name) || ""}, #{description}"
  end

  private

  def create_location_from_suggestion
    return if self.location.present? || self.location_suggestion.blank?
    self.location = Location.new(
      :name => self.location_suggestion,
      :location_type => LocationType.find_by_key("user_suggested")
    )
    true
  end

end
