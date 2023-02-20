class ProductColor < ActiveRecord::Base

  # Relations
  belongs_to :product
  belongs_to :color

end
