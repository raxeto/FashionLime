class HomePageObject < ActiveRecord::Base

  # Relations
  belongs_to :home_page_variant
  belongs_to :object, polymorphic: true

end