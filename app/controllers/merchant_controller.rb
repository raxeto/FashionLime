class MerchantController < ApplicationController

  include Modules::MerchantControllerLib

  def index
    render :layout => "merchant_home"
  end

  protected

  def sections
    [:home]
  end

end
