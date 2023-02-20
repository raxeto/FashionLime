class ContactController < ClientController

  include Modules::ContactControllerLib

  add_breadcrumb "Контакт", :contact_path

  def after_create_path
    root_path
  end

end
