FashionLime.Outfit.product = (function() {
  'use strict';

  var publicData = {

    get: function(product) {
      return HandlebarsTemplates['outfits/product']({
        product: product
      });
    }
  };

  return publicData;
}());
