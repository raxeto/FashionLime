FashionLime.Admin.Campaign.addObjects = (function() {
  'use strict';

  function collectSelectedObjects() {
    var ids = "";
    $('.selected-campaign-objects-list .campaign-object-id').each(function() {
      var id = $(this).text();
      if (!FashionLime.Common.utils.isNullOrEmpty(ids)) {
        ids += ",";
      }
      ids += id;
    });
    if (!FashionLime.Common.utils.isNullOrEmpty(ids)) {
      $('.selected-campaign-ids').val(ids);
    }
    return true;
  }

  var publicData = {
    setup: function(formId) {
      FashionLime.Common.utils.onFormSubmit("#" + formId, function() {
        return collectSelectedObjects();
      });
    },

    addClicked: function(button) {
      var col = $(button).closest('.campaign-object-col');
      col.find('.btn-add').hide();
      $('.selected-campaign-objects-list').append(col);
    },

    removeClicked: function(button) {
      $(button).closest('.campaign-object-col').remove();
    },

    moveLeft: function(button) {
      var col = $(button).closest('.campaign-object-col');
      var prev = $(col).prev();
      if ($(prev).length > 0) {
        col.remove();
        col.insertBefore(prev);
      }
    },

    moveRight: function(button) {
      var col = $(button).closest('.campaign-object-col');
      var next = $(col).next();
      if ($(next).length > 0) {
        col.remove();
        col.insertAfter(next);
      }
    }
  };

  return publicData;
}());
