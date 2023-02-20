class NewsletterController < ClientController

  def subscribe
    email = params[:email]
    success = true
    subscriber = NewsletterSubscriber.find_by_email(email)
    if subscriber.present?
      if subscriber.active == 0
        success = subscriber.update_attributes(:active => 1)
      else
         render json: { status: false, error: "Вече сте бил абониран за нашия бюлетин." }
         return
      end
    else
      subscriber = NewsletterSubscriber.create(:email => email, :user_id => current_or_guest_user.id, :active => 1)
      success = subscriber.persisted?
    end

    if success
      render json: { status: true }
    else
      render json: { status: false, error: "Възникна грешка: #{subscriber.errors.full_messages.join(", ")}"}
    end

  end

end
