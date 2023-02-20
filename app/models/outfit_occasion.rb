class OutfitOccasion < ActiveRecord::Base

  #Relations
  belongs_to :outfit
  belongs_to :occasion

end
