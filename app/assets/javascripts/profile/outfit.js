FashionLime.Profile.outfit = (function() {
  'use strict';

  var publicData = {

    get: function(outfit) {
      return FashionLime.Outfit.partial.get(outfit, "medium", false);
    }
  };
  return publicData;
}());
