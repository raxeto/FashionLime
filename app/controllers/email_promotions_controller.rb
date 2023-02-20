class EmailPromotionsController < ClientController

  add_breadcrumb "Отписване", :email_promotions_successfully_unsubscribed_path
 
public

  def unsubscribe
    email = ActiveSupport::MessageEncryptor.new(Conf.email_promotions.hash_secret).decrypt_and_verify(params[:email_key])
    @user = User.find_by(email: email)
    @subscriber = NewsletterSubscriber.find_by(email: email)
    error_msg = ''

    if @user.present? || @subscriber.present?
      already_unsubscribed = (@user.nil? || !@user.email_promotions) && (@subscriber.nil? || @subscriber.active == 0)
      if already_unsubscribed
        error_msg = I18n.t('controllers.email_promotions.unsubscribe.already_unsubscribed')
      else
        unsubscribed = true
        if @user.present? && !@user.update_attributes(email_promotions: false)
          unsubscribed = false
        end
        if @subscriber.present? && !@subscriber.update_attributes(active: 0)
          unsubscribed = false
        end
        if !unsubscribed
          error_msg = "Възникна грешка при отписването Ви от бюлетина. Тя беше записана в нашата система за грешки. Ще проверим какво е станало."
          Rails.logger.error("User unsubscribe from email promotions error. User id: #{@user.try{:id}}, Subcriber id: #{@subscriber.try(:id)}, Email: #{email}")
        end
      end
    else
      error_msg = I18n.t('controllers.email_promotions.unsubscribe.invalid_user')
    end

    if error_msg.blank?
      redirect_to email_promotions_successfully_unsubscribed_path
    else
      redirect_to root_path, alert: error_msg
    end

  end

end
