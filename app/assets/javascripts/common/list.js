FashionLime.Common.list = (function() {
  'use strict';

  var publicData = {

    setup: function(container, items, itemPartial, wrapperFunc) {
      var html = "";
      for (var i = 0; i < items.length; ++i) {
        var itemHtml = FashionLime.Common.utils.execModelPartial(itemPartial, items[i]);
        if (!FashionLime.Common.utils.isUndefinedOrEmpty(wrapperFunc)) {
          itemHtml = wrapperFunc(itemHtml);
        }
        html += itemHtml;
      }
      $(container).html(html);
    }
  };
  return publicData;
}());
