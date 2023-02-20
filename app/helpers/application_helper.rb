module ApplicationHelper
  def active_class_if_section(matched_section)
    if sections.include? matched_section
      return 'active'
    else
      return ''
    end
  end

  def title(text, include_og_title = false)
    text ||= ''
    site_name_included = (text.include?('Fashion Lime') || text.include?('FashionLime'))
    title_text = text + (site_name_included ? '' : ' | Fashion Lime')
    content_for :title, title_text
    if include_og_title
      og_title_text = text + (site_name_included ? '' : ' във Fashion Lime')
      meta_tag("og:title", og_title_text)
    end
  end

  def description(text, include_og_title = false)
    meta_tag :description, text
    if include_og_title
      meta_tag("og:description", text)
    end
  end

  def meta_tag(tag, text)
    content_for :"meta_#{tag}", text
  end

  def yield_meta_tag(tag, default_text='')
    content_for?(:"meta_#{tag}") ? content_for(:"meta_#{tag}") : default_text
  end

  def allow_search_engine_index
    @allow_search_engine_index = true
  end

  def canonical_url(url)
    @canonical_url = url
  end

  def og_images(images)
    @open_graph_images = images
  end

  def og_image(model, default_image_url = '')
    if model && model.og_image.present?
      og_images([{
          :url    => image_url(model.og_image.url(:original)),
          :type   => model.og_image_content_type,
          :width  => image_width(model.og_image,  :original),
          :height => image_height(model.og_image, :original)
      }])
    elsif default_image_url.present?
       og_images([{
          :url    => image_url(default_image_url),
          :type   => 'image/jpeg',
          :width  => Modules::OpenGraphModel.default_image_width,
          :height => Modules::OpenGraphModel.default_image_height
      }])
    end
  end

  def alert_tag(type, message, title = '')
    alert_class = "alert-#{type.to_s}"
    content_tag(:div, class: "alert #{alert_class} fade in") do
      content_tag(:a, "&times;".html_safe, "href" => "#", "class" => "close", "data-dismiss" => "alert", "aria-label" => "close") +
      (title.present? ? content_tag(:strong, "#{title}&nbsp;".html_safe) : "") +
      message
    end
  end

  def bootstrap_label_tag(type, text)
    label_class = "label-#{type.to_s}"
    content_tag(:span, text, class: "label #{label_class}")
  end

  def color_background_css(color)
    color.background_css()
  end

  def breadcrumbs_class(class_name)
    content_for :breadcrumbs_class, class_name
  end

  def help_steps(location, partial_locations = [])
    @help_steps_location = location
    @help_steps_partial_locations = partial_locations
  end

  def items_array(items)
    ret = "["
    if items.present? 
      items.each do |i|
        ret << (raw i) << ","
      end
    end
    ret << "]"
    ret
  end

  def og_tags(page_link, tag_name)
    tags = OpenGraphTag.where(:page_link => page_link)
    if tag_name == "picture"
      ret = []
      tags.each do |tag|
        if tag.picture?
          ret << {
              :url    => image_url(tag.picture.url(:original)),
              :type   => tag.picture_content_type,
              :width  => tag.picture_width,
              :height => tag.picture_height
          }
        end
      end
      return ret
    else
      if tags[0].present?
        return tags[0][tag_name]
      else
        return nil
      end
    end
  end

end
