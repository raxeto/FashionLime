# Preview all emails at http://localhost:3000/rails/mailers/promotion_mailer
class PromotionMailerPreview < ActionMailer::Preview

  def promotion_email
    email = "ralica.peicheva@gmail.com"
    subject = "Тестово preview на промоционален имейл"
    message_html = "<span style='text-align: center;'>Здравейте, приятели.</span> <br>Вече сме достъпни."
    message_text = ""
    product_collection_ids = "2, 1"
    outfit_ids = "2, 1, 3, 4, 8, 5"
    product_ids = "10, 6, 8, 7, 9, 5"
    query_params = {:utm_campain => "spring", :utm_medium => "email"}
    unsubscribe_url = "http://localhost:3000/email_promotions/unsubscribe/bUVSWFkxR3lTLzlDa0tqVHJyaTN0MFkra2d6ckE3QTdVcW90M3o2MkxJTmJvUmc2Y1VxU213cHRIRmhSbndNMy0tN0JNTWNhSnQwcnRhOE5Mbzk5dVBSdz09--9c42d8159d064b0c6eb857e0bb7022fd59e0a1cf"
    PromotionMailer.promotion_email(email, subject, message_html, message_text, product_collection_ids, outfit_ids, product_ids, query_params, unsubscribe_url)
  end

end
