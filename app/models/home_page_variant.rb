class HomePageVariant < ActiveRecord::Base

  # Relations
  has_many   :home_page_objects, dependent: :destroy

  def self.current
    HomePageVariant.order(created_at: :desc).first
  end

  def object_ids(object_type)
    home_page_objects.select { |o| o.object_type == object_type }.sort_by { |o| o[:order_index] }.map { |o| o.object_id }
  end

end