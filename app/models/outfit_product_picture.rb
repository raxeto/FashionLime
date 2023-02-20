class OutfitProductPicture < ActiveRecord::Base

  # Relations
  belongs_to :outfit
  belongs_to :product_picture

end
