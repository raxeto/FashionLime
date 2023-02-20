FashionLime.Outfit.myOutfit = (function() {
  'use strict';

  var publicData = {

    get: function(outfit) {
      return FashionLime.Outfit.partial.get(outfit, "medium", false, true, "sm", true);
    }
  };
  return publicData;
}());
