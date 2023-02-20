FashionLime.Shared.postBackFilter = (function() {
  'use strict';

  function onFilterChanged(filterName) {
    var url = FashionLime.Common.utils.getPlainUrl();

    var value = $(this).val();
    if (value) {
      url += "?";
      if (FashionLime.Common.utils.isArray(value)) {
        for (var i = 0; i < value.length; ++i) {
          url += filterName + escape('[]') + '=' + encodeURIComponent(value[i]);
          if (i + 1 < value.length) {
            url += '&';
          }
        }
      } else {
        url += (filterName + "=" + encodeURIComponent(value));
      }
      url += '&utf8=' + encodeURIComponent('✓');
    }
    window.location.href = url;
  }

  var publicData = {
    setup: function(filterId, filterName) {
      var filter = $('#' + filterId);
      filter.change(onFilterChanged.bind(filter, filterName));
    }
  };

  return publicData;
}());
