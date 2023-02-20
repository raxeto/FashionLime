FashionLime.Merchant.ProductCollection.form = (function() {
  'use strict';

  var publicData = {
    onPictureSelected: function() {
      $('#picture_image').remove();
      var filePath = $('#picture_input').val();
      var fileName = FashionLime.Common.utils.fileNameFromFilePath(filePath);
      $('#picture_file_name').text(fileName);
    }
  };

  return publicData;
}());

