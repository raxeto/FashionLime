FashionLime.Outfit.utils = (function() {
  'use strict';

  function deleteOutfit(button, id) {
    if (confirm('Сигурни ли сте, че искате да изтриете визията? Действието е необратимо.') === true) {
      FashionLime.Common.net.sendDeleteRequest('/outfits/'+id+'.json', {},
        onDeleteOutfitResponse.bind(button));
    }
  }

  function onDeleteOutfitResponse(response) {
    if (response && response.status) {
      FashionLime.Common.notifications.clear();
      FashionLime.Common.notifications.notify('Успешно изтриване.');
      $(this).closest('.outfit').parent().remove(); // Delete the outfit partial with the whole column
    } else {
      FashionLime.Common.notifications.clear();
      FashionLime.Common.notifications.alert("Възникна грешка при изтриването на визията.");
    }
  }

  var publicData = {
    delete: function(button, id) {
      deleteOutfit(button, id);
    },

    loadCanvasContent: function(canvas, serializedJSON, contentLoadedEvent) {
      if (!FashionLime.Common.utils.isNullOrEmpty(serializedJSON)) {
        canvas.loadFromJSON(serializedJSON, function () {
          canvas.forEachObject(function(o) {
            if (o instanceof fabric.Image && o.filters.length > 0) {
              o.applyFilters(canvas.renderAll.bind(canvas));
            }
          });
          canvas.renderAll();
          if (!FashionLime.Common.utils.isUndefined(contentLoadedEvent)) {
            contentLoadedEvent();
          }
        });
      }
    }
  };

  return publicData;
}());
