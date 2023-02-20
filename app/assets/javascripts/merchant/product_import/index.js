FashionLime.Merchant.ProductImport.index = (function() {
  'use strict';

  function onBrowseFileChanged() {
    var filePath = $(this).val();
    var fileName = FashionLime.Common.utils.fileNameFromFilePath(filePath);
    $('#fileName').text(fileName);
  }

  function onFormSubmit() {
    var file = $('#import_file').val();
    if (!file) {
      alert('Не е избран файл за импорт.');
      return false;
    }
    return true;
  }

  var publicData = {
    setup: function() {
      $('#import_file').change(onBrowseFileChanged);
      FashionLime.Common.utils.onFormSubmit('#importProductsForm', onFormSubmit);
    },
    showPreviewSections: function(previewSuccess) {
      if (previewSuccess) {
        $('#previewSuccess').show();
        $('#previewErrors').hide();
      } else {
        $('#previewSuccess').hide();
        $('#previewErrors').show();
      }
    }
  };

  return publicData;
}());
