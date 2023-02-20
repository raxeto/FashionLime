FashionLime.Outfit.relatedItem = (function() {
  'use strict';

  var publicData = {

    get: function(outfit) {
      return FashionLime.Outfit.partial.get(outfit, "thumb", true, false, "xs");
    }
  };
  return publicData;
}());
