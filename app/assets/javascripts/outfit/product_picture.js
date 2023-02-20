FashionLime.Outfit.productPicture = (function() {
  'use strict';

  var publicData = {

    get: function(productPicture) {
      return HandlebarsTemplates['outfits/product_picture']({ 
        picture: productPicture,
        locals: {
          image_class: productPicture.outfit_compatible == 1 ? "transparent-background" : ""
        } 
      });
    }
  };

  return publicData;
}());
