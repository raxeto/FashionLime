class ProductSize < ActiveRecord::Base

  # Relations
  belongs_to :product
  belongs_to :size

end
