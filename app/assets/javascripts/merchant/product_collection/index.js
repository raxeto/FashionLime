FashionLime.Merchant.ProductCollection.index = (function() {
  'use strict';

  function onDeleteCollectionClicked() {
    var collectionId = $(this).siblings('.collection-id').val();
    if (confirm('Сигурни ли сте, че искате да изтриете тази колекция?')) {
      FashionLime.Common.net.sendDeleteRequest(
        '/merchant/product_collections/'+collectionId+'.json', 
        {},
        function(response) {
          location.reload();
        }
      );
    }
  }

  var publicData = {
    setup: function() {
      $('.btn-delete-collection').click(onDeleteCollectionClicked);
    }
  };

  return publicData;
}());

