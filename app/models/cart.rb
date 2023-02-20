class Cart < ActiveRecord::Base

  include Modules::StatLib

  # Attributes
  currency_accessor :total, :total_with_discount, :total_visible_with_discount

  # Relations
  has_one  :user
  has_many :cart_details, dependent: :destroy
  accepts_nested_attributes_for :cart_details, allow_destroy: true

public

  def empty?
    cart_details.empty?
  end

  def item_count
    cnt = 0
    cart_details.each do |cd|
      cnt += cd.qty
    end
    cnt
  end

  def transfer_from(source_cart)
    return if source_cart.nil? || source_cart.empty?

    ActiveRecord::Base.transaction do
      has_db_error = false
      source_cart.cart_details.each do |detail_from|
        begin
          if article_exists?(detail_from.article_id)
            unless update_existing_article(detail_from.article, detail_from.qty)
              has_db_error = true
            end
            detail_from.destroy_without_log()
          else
            unless detail_from.update_attributes(cart_id: id)
              has_db_error = true
            end
          end
        rescue ActiveRecord::ActiveRecordError
          has_db_error = true
        end
        if has_db_error
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def total
    cart_details.sum(:total)
  end

  def total_with_discount
    cart_details.sum(:total_with_discount)
  end

  def total_visible_with_discount
    Product.visible.joins(articles: [:cart_details]).where("cart_details.cart_id = ?", id).sum(:total_with_discount)
  end

  def update_detail(cart_detail_id, updated_qty)
    check_qty_number(updated_qty)

    detail = cart_details.find_by_id(cart_detail_id)
    if detail.nil?
      raise "Артикулът вече не съществува."
    end

    if not detail.article.has_available_qty?(updated_qty)
      raise "Няма налично желаното количество от този артикул."
    end

    has_db_error = false
    begin
        has_db_error = !update_existing_detail(detail, updated_qty)
    rescue ActiveRecord::ActiveRecordError
      has_db_error = true
    end

    if (has_db_error)
      raise "Възникна грешка при редактирането на количеството в количката."
    end
  end

  def add_article(article, qty_demand)
    check_qty_number(qty_demand)

    art_exists = article_exists?(article.id)
    detail = cart_details.find_by(article_id: article.id)

    new_qty = qty_demand + (art_exists ? detail.qty : 0.0)
    if !article.has_available_qty?(new_qty)
      raise "Няма налично желаното количество от този артикул и той не може да бъде добавен."
    end

    has_db_error = false
    begin
      if art_exists
        has_db_error = !update_existing_article(article, qty_demand)
      else
        has_db_error = !add_not_existing_article(article, qty_demand)
      end
    rescue ActiveRecord::ActiveRecordError
      has_db_error = true
    end

    if (has_db_error)
      raise "Възникна грешка при добавянето на артикула в количката."
    end
  end


  def make_empty_after_order
    ret = true
    ActiveRecord::Base.transaction do
      cart_details.each do |d|
        begin
            has_db_error = !d.destroy_without_log()
        rescue ActiveRecord::ActiveRecordError
          has_db_error = true
        end
        if has_db_error
          ret = false
          raise ActiveRecord::Rollback
        end
      end
    end
    ret
  end

  def add_not_existing_article(article, new_qty)
    detail_attributes = create_detail_attributes(article, new_qty)
    detail = cart_details.create(detail_attributes)
    return detail.valid?
  end

  def update_existing_article(article, qty_demand)
    detail = cart_details.find_by(article_id: article.id)
    return update_existing_detail(detail, detail.qty + qty_demand)
  end

  def update_existing_detail(detail, new_qty)
    detail_attributes = create_detail_attributes(detail.article, new_qty)
    return detail.update_attributes(detail_attributes)
  end

  def article_exists?(art_id)
    return !cart_details.find_by(article_id: art_id).nil?
  end

  def check_qty_number(q)
    if q < Conf.math.QTY_EPSILON
      raise "Количеството трябва да е по-голямо от 0."
    end
  end

  def create_detail_attributes(article, new_qty)
    detail_attributes =
      {
        article_id: article.id,
        price: article.price,
        perc_discount: article.perc_discount,
        price_with_discount: article.price_with_discount,
        qty: new_qty
      }
  end

end
