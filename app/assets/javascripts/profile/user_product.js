FashionLime.Profile.userProduct = (function() {
  'use strict';

  var publicData = {

    get: function(product) {
      return FashionLime.Product.partial.get(product, "medium", true);
    }
  };
  return publicData;
}());
