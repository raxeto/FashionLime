class AdminMailer < ApplicationMailer

  include Modules::ClientUrlLib

  def new_failed_order_payment(order_id)
    subject = "Неуспешно създаване на поръчка с ID: #{order_id}"
    emails = admin_emails
    @order_id = order_id
    mail(to: emails, subject: subject)
  end

  def new_failed_svg_serialization(outfit_id)
    subject = "Неуспешно конвертиране на SVG към PNG във визия с ID: #{outfit_id}"
    emails = admin_emails
    @outfit_id = outfit_id
    outfit = Outfit.find_by(id: outfit_id)
    if outfit.present?
      @outfit_url = outfit_path(outfit)
    else
      @outfit_url = '<визия с такова ID не бе намерена в базата>'
    end
    mail(to: emails, subject: subject)
  end

  def new_slow_request_tracked(request_time, slow_url)
    subject = "Беше регистриран рекуест с време: #{request_time} секунди"
    @slow_url = slow_url
    emails = admin_emails
    mail(to: emails, subject: subject)
  end

  def new_server_epoll_bellow_50(total_time)
    subject = "Сървърът беше натоварен #{total_time} секунди в последната минута"
    emails = admin_emails
    mail(to: emails, subject: subject)
  end

  def new_bad_requests_tracked(errors)
    subject = "Бяха регистрирани #{errors.size} лоши рекуести"
    @errors = errors
    emails = admin_emails
    mail(to: emails, subject: subject)
  end

  def new_problem_occurred_email(message)
    subject = "Случи се неочакван проблем"
    @message = message
    emails = admin_emails
    mail(to: emails, subject: subject)
  end

  def admin_emails
    User.admins.pluck(:email)
  end

end
