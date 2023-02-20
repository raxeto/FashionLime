class ArticleQuantity < ActiveRecord::Base

  # Relations
  belongs_to :article

  # Validations
  validates_numericality_of :qty, :greater_than => 0
  validate  :sold_available_qty_diff

  # Callbacks
  before_destroy :sold_qty_exists
  after_create  -> (q) { q.update_available_qty(q.available_qty, 0.0) }
  after_update  -> (q) { q.update_available_qty(q.available_qty, q.available_qty_was) }
  after_destroy -> (q) { q.update_available_qty(0.0, q.available_qty) }

  public

  def available_qty
    calc_available_qty(qty, qty_sold, active)
  end

  def available_qty_was
    q = qty_changed? ? qty_was : qty
    qs = qty_sold_changed? ? qty_sold_was : qty_sold
    a = active_changed? ? active_was : active

    calc_available_qty(q, qs, a)
  end

  def part_text
    "[#{id}]#{part}"
  end

  protected

  def update_available_qty(new_availabe_qty, old_availabe_qty)
    article.update(available_qty: article.available_qty + new_availabe_qty - old_availabe_qty)
  end

  private

  def sold_available_qty_diff
    if !((qty - qty_sold) > -Conf.math.QTY_EPSILON)
      errors.add(:qty, "не може да променяте количеството да е по-малко от това, което вече е продадено")
    end
  end

  def sold_qty_exists
    ret = (qty_sold < Conf.math.QTY_EPSILON)
    if !ret
      errors.add(:qty, "по това количество има направени продажби и не може да бъда изтрито")
    end
    ret
  end

  def calc_available_qty(q, qs, a)
    if a == 0
      return 0.0
    end
    return q - qs
  end

end
