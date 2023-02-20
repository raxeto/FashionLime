class CampaignObject < ActiveRecord::Base

  # Relations
  belongs_to :campaign
  belongs_to :object, polymorphic: true

end
