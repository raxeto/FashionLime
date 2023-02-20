class Article < ActiveRecord::Base

  # Attributes
  currency :price, :price_with_discount
  attr_accessor :should_send_min_qty_email

  # Relations
  belongs_to  :product
  belongs_to  :size
  belongs_to  :color

  has_many :article_quantities, dependent: :destroy
  has_many :cart_deleted_details, dependent: :destroy
  has_many :cart_details, dependent: :restrict_with_error
  has_many :merchant_order_details, dependent: :restrict_with_error

  accepts_nested_attributes_for :article_quantities

  # Validations
  validates_presence_of :size_id
  validates_presence_of :color_id
  validates_numericality_of :price, :greater_than => 0
  validates_numericality_of :perc_discount, :greater_than_or_equal_to => 0, :less_than => 100

  # Callbacks
  before_save :set_price_with_discount
  after_update :send_min_available_qty_email

  after_commit :update_es_indexes_on_save, on: [:update]
  after_commit :update_es_indexes_on_destroy, on: [:destroy]
  after_commit :reload_product_cache, on: [:update, :destroy]
  after_commit :reload_outfit_cache, on: [:update, :destroy]

  public

  def full_name
    "#{product.name}, Цвят: #{color.name}, Размер: #{size.name}"
  end

  def color_size_combo_name
    "Цвят: #{color.name}, Размер: #{size.name}"
  end

  def has_available_qty?(qty_demand)
    available_qty - qty_demand > -Conf.math.QTY_EPSILON
  end

  def self.available_clause
    return "available_qty >= #{Conf.math.QTY_EPSILON}"
  end

  def available?
    available_qty >= Conf.math.QTY_EPSILON
  end

  def update_available_quantity(new_available_qty)
    new_available_qty = new_available_qty || 0
    # Qty is equal
    if (new_available_qty - available_qty).abs < Conf.math.QTY_EPSILON
      return true
    end
    # Qty is greater
    if new_available_qty > available_qty
      new_qty = ArticleQuantity.create(:article_id => id, :qty => (new_available_qty - available_qty).to_i)
      if !new_qty.persisted?
        Rails.logger.error("Error creating new article quantity: #{new_qty.errors.full_messages}.")
        return false
      end
      return true
    end

    # Qty is less
    success = true
    begin
      diff = available_qty - new_available_qty
      quantities = article_quantities.select {|q| q.active == 1 && (q.qty - q.qty_sold).abs >= Conf.math.QTY_EPSILON }
      quantities.each do |q|
        if diff <= 0
          break
        end
        q_available_qty = q.qty - q.qty_sold
        if q_available_qty <= diff
          diff -= q_available_qty

          if !q.update_attributes(:active => 0) # Deactivate the whole quantity.
            Rails.logger.error("Error decativating quantity: #{q.errors.full_messages}.")
            return false
          end
        else
          if !q.update_attributes(:qty => q.qty - diff)
            Rails.logger.error("Error updating quantity: #{q.errors.full_messages}.")
            return false
          end
          break
        end
      end
    rescue StandardError => e
      Rails.logger.error("Error while updating available quantity: #{e}.")
      success = false
    end
    return success
  end

  private

  def send_min_available_qty_email
    if should_send_min_qty_email && product.min_available_qty.present?
      # Send email when available_qty become less than min_available_qty for the first time
      if (product.min_available_qty - available_qty) > -Conf.math.QTY_EPSILON && (available_qty_was - product.min_available_qty) >= Conf.math.QTY_EPSILON
        ProductMailer.merchant_min_available_qty(self).deliver_now
      end
    end
  end

  def update_es_indexes_on_destroy
    update_es_indexes
  end

  def update_es_indexes_on_save
    if did_attr_change?(:price_with_discount) || did_attr_change_from_or_to_zero?(:available_qty)
      self.reload
      update_es_indexes
    end
  end

  def update_es_indexes
    if product.nil?
      # We have deleted the product, which has triggered a delete on all of it's articles.
      return
    end

    Modules::DelayedJobs::EsIndexer.schedule('update_document', product)

    # TODO: fix this check - it's wrong.
    # Hmm, why wrong? It seems like the only problem is, that we store min and max
    # price for the article and we don't cover the max price case.
    if product.min_price(true) == price_with_discount
      Outfit.with_product(product.id).each do |outfit|
        Modules::DelayedJobs::EsIndexer.schedule('update_document', outfit)
      end
    end
  end

  def reload_product_cache
    # In the other cases article is updated through product and then product after_commit is called
    # which updates product cache
    # TODO check why this don't work in article quantity update, but works in order new
    if did_attr_change_from_or_to_zero?(:available_qty)
      Modules::ProductJsonBuilder.instance.refresh_product_cache(product.id) if product.present?
    end
  end

  def reload_outfit_cache
    # TODO check as for the product cache why  did_attr_change_from_or_to_zero?(:available_qty)
    # is not working when updating article quantity. For product it's ok because the product after commit callback refreshes the cache.
    # But for outfits it's not because refreshing of the cache is called only here.
    if product.present?
      Outfit.with_product(product.id).each do |outfit|
        Modules::OutfitJsonBuilder.instance.refresh_outfit_cache(outfit.id)
      end
    end
  end

  def set_price_with_discount
    self.price_with_discount = calc_price_with_discount(price, perc_discount)
    true
  end

end
