class AdminMailerPreview < ActionMailer::Preview

  def new_failed_order_payment
    AdminMailer.new_failed_order_payment(14)
  end

  def new_failed_svg_serialization
    AdminMailer.new_failed_svg_serialization(3)
  end

  def new_slow_request_tracked
    AdminMailer.new_slow_request_tracked(3.414231, 'google.com')
  end

  def new_server_epoll_bellow_50
    AdminMailer.new_server_epoll_bellow_50(34.51)
  end

  def new_bad_requests_tracked
    errors = [
      '0.0.0.0 - - [04/Apr/2017:21:52:07 +0300] "GET https://fashionlime.bg/ping HTTP/1.1" 500 33 "-" "Ruby" (0.003) (0.003) .',
      '0.0.0.0 - - [04/Apr/2017:22:52:07 +0300] "GET https://fashionlime.bg/ping HTTP/1.1" 500 33 "-" "Ruby" (0.003) (0.003) .'
    ]
    AdminMailer.new_bad_requests_tracked(errors)
  end

end
