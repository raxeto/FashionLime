class SizeCategoryProductCategory < ActiveRecord::Base

  # Relations 
  belongs_to  :size_category
  belongs_to  :product_category

end
