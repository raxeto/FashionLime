FashionLime.Shared.fileInput = (function() {

  function setAjaxFileInputDefaults() {
    $.ajaxSetup({
        dataType: null,
        headers: null,
        timeout: 60000
    });
  }

  var publicData = {
    setup: function() {
      setAjaxFileInputDefaults();
    },

    setupFromCache: function() {
      setAjaxFileInputDefaults();
    },

    cleanup: function() {
      FashionLime.Common.net.initJQueryAjax();
    }
  };

  return publicData;
}());
