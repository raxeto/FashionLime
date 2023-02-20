FashionLime.Admin.User.avatars = (function() {
  'use strict';

  function deleteAvatar(button, id) {
    if (confirm('Сигурни ли сте, че искате да изтриете аватара? Действието е необратимо.') === true) {
      FashionLime.Common.net.sendDeleteRequest('/admin/users/'+id+'/destroy_avatar.json', {},
        onDeleteAvatarResponse.bind(button));
    }
  }

  function onDeleteAvatarResponse(response) {
    if (response && response.status) {
      alert('Успешно изтриване.');
      $(this).closest('.avatar-container').remove();
    } else {
      alert("Възникна грешка при изтриването." + response.error);
    }
  }

  var publicData = {
    delete: function(button, id) {
      deleteAvatar(button, id);
    }
  };

  return publicData;
}());
