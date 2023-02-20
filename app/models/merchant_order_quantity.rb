class MerchantOrderQuantity < ActiveRecord::Base

  # Relations
  belongs_to :article_quantity

  # Callbacks
  after_create  -> (q) { q.update_sold_qty(q.qty, 0.0) }
  after_update  -> (q) { q.update_sold_qty(q.qty, q.qty_was) }
  after_destroy -> (q) { q.update_sold_qty(0.0, q.qty) }

  protected

  def update_sold_qty(new_sold_qty, old_sold_qty)
    begin
      article_quantity.article.should_send_min_qty_email = true
      if !article_quantity.update_attributes(qty_sold: article_quantity.qty_sold + new_sold_qty - old_sold_qty)
        raise "Няма налично желаното количество от този артикул и той не може да бъде добавен."
      end
    rescue ActiveRecord::StaleObjectError
      raise "Възникна конфликт с друг потребител при поръчката на този артикул. Моля, опитайте отново."
    rescue ActiveRecord::ActiveRecordError
      raise e.message
    rescue StandardError => e
      raise e.message
    end
    
  end
end
