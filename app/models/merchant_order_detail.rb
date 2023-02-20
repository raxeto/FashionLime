class MerchantOrderDetail < ActiveRecord::Base

  # Attributes
  attr_accessor :allow_prices_change
  currency :price, :price_with_discount, :total, :total_with_discount

  # Relations
  belongs_to :merchant_order
  belongs_to :article
  has_one    :merchant_order_return_detail

  has_many   :merchant_order_quantities, dependent: :destroy
  has_many   :article_quantities, :through => :merchant_order_quantities

  # Validations
  validates_presence_of :article_id
  validates_numericality_of :qty, :greater_than => 0
  validates_numericality_of :price, :greater_than => 0
  validates_numericality_of :perc_discount, :greater_than_or_equal_to => 0, :less_than => 100

  # Callbacks
  before_create :check_price, if: :validate_prices?
  before_save :calc_totals, :sync_order_quantities

  def total_qty
    qty - qty_to_return - qty_returned
  end

  def calc_totals
    self.price_with_discount = calc_price_with_discount(price, perc_discount)
    self.total = (self.price * self.total_qty).round(2)
    self.total_with_discount = (self.price_with_discount * self.total_qty).round(2)
    true
  end

  def is_price_changed?
    self.price != self.article.price || 
    self.perc_discount != self.article.perc_discount ||
    self.price_with_discount != self.article.price_with_discount
  end

  def reset_price
    self.price = self.article.price 
    self.perc_discount = self.article.perc_discount 
    self.price_with_discount = self.article.price_with_discount

    calc_totals()
  end

  def parts_text
    article_quantities.map { |q| q.part_text }.uniq.join(',')
  end

  private

  def check_price
    if is_price_changed?
      reset_price()
      errors.add("changed_prices", "Цените за този артикул вече са променени - моля прегледайте новите цени и направете поръчката, ако те Ви удовлетворяват.")
      return false
    end
    true
  end

  def sync_order_quantities
    old_qty = merchant_order_quantities.sum(:qty)
    new_qty = (qty - qty_returned)
    diff = new_qty - old_qty

    return true if diff.abs < Conf.math.QTY_EPSILON

    ret = true
    if diff > 0.0
      article.article_quantities.where(
        "active = 1 AND (qty - qty_sold) >= ?", Conf.math.QTY_EPSILON).order(:id).each do |aq|
        qty_take = [aq.available_qty, diff].min
        merchant_order_quantities.build(article_quantity_id: aq.id, qty: qty_take)
        diff -= qty_take
        break if diff < Conf.math.QTY_EPSILON
      end
      ret = diff < Conf.math.QTY_EPSILON
    else
      diff = diff.abs
      db_has_errors = false
      merchant_order_quantities.order(article_quantity_id: :desc).each do |qa|
        begin
          qty_to_change = diff - qa.qty
          if qty_to_change >= 0
            qa.destroy!()
          else
            db_has_errors = qa.update(qty: qty_to_change.abs) == 0
          end
          diff = qty_to_change
        rescue ActiveRecord::ActiveRecordError
          db_has_errors = true
        end
        if db_has_errors
          ret = false
          break
        end
        break if diff < 0.0
      end
    end

    if !ret
      errors.add("available_qty", "Желаното от Вас количество не е налично и не може да бъде закупено.")
    end

    ret
  end

  def validate_prices?
    return !allow_prices_change
  end

end
