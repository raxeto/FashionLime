FashionLime.Product.relatedItem = (function() {
  'use strict';

  var publicData = {

    get: function(product) {
      return FashionLime.Product.partial.get(product, "thumb", true, false, "xs", "picture-watermark-sm");
    }
  };
  return publicData;
}());
