class MerchantOrderReturn < ActiveRecord::Base

  include Modules::PublicUserModel

  # Attributes
  enum status: { active: 1, waiting_return: 2, closed: 3 }

  # Relations
  belongs_to :merchant_order
  belongs_to :user
  has_many   :merchant_order_return_details
  accepts_nested_attributes_for :merchant_order_return_details, allow_destroy: false

  # Validations
  validates_presence_of :merchant_order
  validates_presence_of :user_first_name
  validates_presence_of :user_last_name
  validates_presence_of :user_phone
  validates :user_email, email: true, presence: true
  validate  :same_merchant_order
  validate  :only_one_return_per_order, on: :create

  # Scopes
  scope :active, -> { where(status: 1) }


  def number
    merchant_order.return_code
  end

  def self.new_from_order(merchant_order)
    order_return = MerchantOrderReturn.new

    order_return.user_first_name = merchant_order.order.user_first_name
    order_return.user_last_name = merchant_order.order.user_last_name
    order_return.user_email = merchant_order.order.user_email
    order_return.user_phone = merchant_order.order.user_phone

    order_return.merchant_order = merchant_order
    merchant_order.merchant_order_details.each do |d|
      order_return.merchant_order_return_details.build({
        :merchant_order_detail => d,
        :return_qty => d.qty
      })
    end
    return order_return
  end

  def process_returns
    return false unless check_details_status(:return, :not_processed)
    update_details_status_in_trans(:return, :waiting_return)
  end

  def process_exchanges(new_articles)
    return false unless check_details_status(:exchange, :not_processed)
    success = true
    ActiveRecord::Base.transaction do
      begin
        success = update_details_status(:exchange, :waiting_return)
        if success
          success = insert_new_articles(new_articles)
        end
      rescue ActiveRecord::ActiveRecordError, ActiveRecord::StaleObjectError, StandardError
        success = false
      end
      if !success
        raise ActiveRecord::Rollback
      end
    end
    success
  end

  def reasons_str
    merchant_order_return_details.map { |d| d.return_type_i18n }.uniq.join(', ')
  end

  def mark_details_as_returned(return_type)
    return false unless check_details_status(return_type, :waiting_return)
    update_details_status_in_trans(return_type, :returned)
  end

  private

  def update_details_status(return_type, new_status)
    merchant_order_return_details.each do |d|
      if d.return_type == return_type.to_s
        unless d.update_attributes(:status => MerchantOrderReturnDetail.statuses[new_status])
          return false
        end
      end
    end
    true
  end

  def update_details_status_in_trans(return_type, new_status)
    success = true
    ActiveRecord::Base.transaction do
      begin
        success = update_details_status(return_type, new_status)
      rescue ActiveRecord::ActiveRecordError, ActiveRecord::StaleObjectError, StandardError
        success = false
      end
      if !success
        raise ActiveRecord::Rollback
      end
    end
    success
  end

  def check_details_status(return_type, expected_status)
    !merchant_order_return_details.where("return_type = ? and status != ?",
      MerchantOrderReturnDetail.return_types[return_type],
      MerchantOrderReturnDetail.statuses[expected_status]).exists?
  end

  def insert_new_articles(new_articles)
    merchant = merchant_order.merchant
    new_articles.each do |a|
      article = merchant.articles.find_by_id(a["article_id"])
      if article.present?
        return false if !merchant_order.merchant_order_details.create(
          :article_id => article.id,
          :price => article.price,
          :perc_discount => article.perc_discount,
          :price_with_discount => article.price_with_discount,
          :qty => a["qty"]
        )
      end
    end
    true
  end

  def same_merchant_order
    merchant_order_return_details.each do |d|
      if (d.merchant_order_detail.try(:merchant_order_id) || 0) != merchant_order_id
        errors.add(:merchant_order_mismatch_detail, "Несъвпадаща поръчка и продукти.")
        return
      end
    end
  end

  def only_one_return_per_order
    if MerchantOrderReturn.where(:merchant_order_id => merchant_order_id).size > 0
      errors.add(:merchant_order_id, "Може да генерирате само една заявка за връщане на поръчка.")
    end
  end

end
