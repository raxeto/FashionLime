class MerchantOrderReturnDetail < ActiveRecord::Base

  # Attributes
  enum return_type: { return: 1, exchange: 2 }
  enum status:      { not_processed: 1, waiting_return: 2, returned: 3 }
  currency_accessor :return_total

  # Relations
  belongs_to :merchant_order_return
  belongs_to :merchant_order_detail

  # Validations
  validates_presence_of     :merchant_order_detail
  validates_presence_of     :return_type
  validates_numericality_of :return_qty, :greater_than => Conf.math.QTY_EPSILON
  validate                  :return_qty_less_than_ordered

  # Callbacks
  before_create :only_one_return_detail_per_order
  before_save   :update_order_detail_qty
  after_update  :update_order_return_status

  def return_total
    merchant_order_detail.price_with_discount * return_qty
  end

  def return_qty_less_than_ordered
    if (return_qty - (merchant_order_detail.try(:qty) || 0)) >= Conf.math.QTY_EPSILON
      errors.add(:return_qty, "трябва да е по-малко или равно на поръчаното количество")
    end
  end

  def only_one_return_detail_per_order
    if MerchantOrderReturnDetail.where(:merchant_order_detail_id => merchant_order_detail_id).size > 0
      errors.add(:merchant_order_detail_id, "Може да генерирате само един ред от заявка за връщане на продукт.")
      return false
    end
    true
  end

  def update_order_detail_qty
    if status_changed?
      if status == "waiting_return"
        return merchant_order_detail.update_attributes(:qty_to_return => return_qty)
      elsif status == "returned"
        return merchant_order_detail.update_attributes(:qty_to_return => 0.0, :qty_returned => return_qty)
      end
    end
    true
  end

  def update_order_return_status
    if status_changed?
      return_order_status = MerchantOrderReturn.statuses[:closed]
      merchant_order_return.merchant_order_return_details.each do |d|
        if d.not_processed?
          # Exists not processed detail
          return_order_status = MerchantOrderReturn.statuses[:active]
          break
        end
        if d.waiting_return?
          # Exists waiting return detail and not exists not processed detail (no break)
          return_order_status = MerchantOrderReturn.statuses[:waiting_return]
        end
      end
      return merchant_order_return.update_attributes(:status => return_order_status)
    end
    true
  end

end
