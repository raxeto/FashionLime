(function() {
  'use strict';

  FashionLime.Devise.EditUser = function(formId, inputsRequiringPassword, passwordFormGroup, showInitially) {
    if (!showInitially) {
      $(passwordFormGroup).hide();
    }
    for (var i = 0; i < inputsRequiringPassword.length; ++i) {
      $(formId).find(inputsRequiringPassword[i]).change(function(event) {
        $(passwordFormGroup).show();
      });
    }

    $("#pick-new-avatar").change(this.onAvatarChanged);
  };

  FashionLime.Devise.EditUser.prototype = {
    onAvatarChanged: function() {
      $('#avatar-image').remove();
      var filePath = $('#pick-new-avatar').val();
      var fileName = FashionLime.Common.utils.fileNameFromFilePath(filePath);
      $('#avatar-file-name').text(fileName);
    }
  };

}());
