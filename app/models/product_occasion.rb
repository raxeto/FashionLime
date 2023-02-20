class ProductOccasion < ActiveRecord::Base

  #Relations
  belongs_to :product
  belongs_to :occasion

end
