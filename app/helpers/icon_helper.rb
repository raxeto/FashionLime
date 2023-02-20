module IconHelper

  def product_icon(options = {})
    flat_icon("flaticon-tool-1", options)
  end

  def outfit_icon(options = {})
    flat_icon("flaticon-mannequin-1", options)
  end

  def product_collection_icon(options = {})
    flat_icon("flaticon-shirts", options)
  end

  private

  def flat_icon(icon_name, options = {})
    options[:class] = "flaticon #{icon_name} #{options[:class]}"
    options["aria-hidden"] = "true"
    content_tag(:i, '', options)
  end

end
