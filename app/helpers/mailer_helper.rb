module MailerHelper

  def mailer_link_to(*args, &block)
    html_options = { :target => "_blank" }
    if block_given?
      if args[0].present?
        args[0] = append_query_params(args[0], @query_params)
      end
      args[1] = (args[1] || {}).merge(html_options)
    else
      if args[1].present?
        args[1] = append_query_params(args[1], @query_params)
      end
      args[2] = (args[2] || {}).merge(html_options)
    end

    link_to(*args, &block)
  end

  def mailer_url(url)
    append_query_params(url, @query_params)
  end

  private

  def append_query_params(url, query_params)
    if query_params.nil?
      return url
    end
    query = query_params.to_query
    if url.include?("?")
      return "#{url}&#{query}"
    else
      return "#{url}?#{query}"
    end
  end

end
