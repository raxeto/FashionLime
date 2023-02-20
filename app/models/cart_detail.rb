class CartDetail < ActiveRecord::Base

  include Modules::StatLib

  # Attributes
  currency :price, :price_with_discount, :total, :total_with_discount

  # Relations
  belongs_to :cart
  belongs_to :article
  accepts_nested_attributes_for :article

  # Validations
  validates_numericality_of :qty, :greater_than => 0

  # Callbacks
  before_save   :update_sums
  after_destroy :log_deleted_record

  public

  # Delete the record without calling log callback
  def destroy_without_log
    CartDetail.delete(id) == 1
  end

  def client_data
    return {
      id: id,
      total: article.product.is_visible? ? total_with_discount : 0.0,
    }.to_json
  end

  private

  def update_sums
    self.total = (price * qty).round(2)
    self.total_with_discount = (price_with_discount * qty).round(2)
    true
  end

  def log_deleted_record
    log_stat(:cart_deleted_articles,
    {
      :user_id => cart.user_id,
      :article_id => article_id,
      :price => price,
      :perc_discount => perc_discount,
      :price_with_discount => price_with_discount,
      :qty => qty,
      :added_at => created_at
    })
  end

end
