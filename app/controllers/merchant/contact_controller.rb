class Merchant::ContactController < MerchantController

  include Modules::ContactControllerLib

  add_breadcrumb "Помощ за търговци", :merchant_contact_path

  def after_create_path
    merchant_root_path
  end

end
