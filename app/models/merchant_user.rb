class MerchantUser < ActiveRecord::Base

  # Relations
  belongs_to :merchant
  belongs_to :user
end
