FashionLime.Outfit.listItem = (function() {
  'use strict';

  var publicData = {

    get: function(outfit) {
      return FashionLime.Outfit.partial.get(outfit, "medium");
    }
  };
  return publicData;
}());
