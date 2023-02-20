FashionLime.Product.listItem = (function() {
  'use strict';

  var publicData = {

    get: function(product) {
      return FashionLime.Product.partial.get(product, "medium");
    }
  };
  return publicData;
}());
