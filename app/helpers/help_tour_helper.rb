module HelpTourHelper
 
  def help_tour_steps(location, partial_locations)
    steps = []
    if location.present?
      path = ["help_tour"]
      controller_path.split('/').each do |p| 
        path.push(p.singularize)
      end
      path.push(location, "steps")
      steps += I18n.t(path.join('.'))
    end
    if partial_locations.present?
      partial_locations.each do |part_loc|
        partial_steps = I18n.t("help_tour.#{part_loc[:location]}.steps")
        if part_loc[:start_index].present?
          steps.insert(part_loc[:start_index], *(partial_steps))
        else
          steps += partial_steps
        end
      end
    end
    steps.to_json.html_safe
  end
  
end
