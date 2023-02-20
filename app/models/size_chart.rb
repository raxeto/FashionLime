class SizeChart < ActiveRecord::Base

  # Relations
  belongs_to  :merchant
  belongs_to  :size_category

  has_many :size_chart_descriptors, -> { order("order_index") }, dependent: :destroy
  accepts_nested_attributes_for :size_chart_descriptors, allow_destroy: false

  # Validations
  validates_presence_of :name
  validates_presence_of :size_category_id
  validate  :one_size_chart_per_size_category, :on => :create

  private

  def one_size_chart_per_size_category
    if SizeChart.where(:merchant_id => merchant_id, :size_category_id => size_category_id).exists?
      errors.add(:size_category_id, "за тази категория размер вече имате създадена таблица с размери - ако искате да я пресъздадете трябва първо да изтриете старата")
    end
  end

end
