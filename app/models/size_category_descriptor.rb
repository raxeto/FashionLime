class SizeCategoryDescriptor < ActiveRecord::Base

  # Relations
  belongs_to  :size_category
  belongs_to  :size_descriptor

end
