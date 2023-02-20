FashionLime.Outfit.decorationPartial = (function() {
  'use strict';

  var publicData = {

    get: function(decoration) {
      return HandlebarsTemplates['outfits/outfit_decoration']({
        decoration: decoration
      });
    }
  };

  return publicData;
}());
