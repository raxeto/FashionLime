class MerchantProductApiMapping < ActiveRecord::Base
  
  # Relations
  belongs_to :merchant
  belongs_to :object, polymorphic: true
  
end
