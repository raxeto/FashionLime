FashionLime.Profile.merchantProduct = (function() {
  'use strict';

  var publicData = {

    get: function(product) {
      return FashionLime.Product.partial.get(product, "medium", false);
    }
  };
  return publicData;
}());
