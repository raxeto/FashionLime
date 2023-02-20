FashionLime.Merchant.Merchant.editMerchant = (function() {
  'use strict';

  var publicData = {
    onLogoSelected: function() {
      $('#logo_image').remove();
      var filePath = $('#logo_input').val();
      var fileName = FashionLime.Common.utils.fileNameFromFilePath(filePath);
      $('#logo_file_name').text(fileName);
    }
  };

  return publicData;
}());

