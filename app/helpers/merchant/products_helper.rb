module Merchant::ProductsHelper

  def add_picture_link(name)
    render :partial => 'picture', :locals => { :object => ProductPicture.new }
  end

end
