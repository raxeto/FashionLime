FashionLime.Admin.OutfitDecoration.editOrderIndex = (function() {
  'use strict';

  function onLeftButtonClicked() {
    var decorationCol = $(this).closest('.decoration-col');
    var prev = $(decorationCol).prev();
    if ($(prev).length > 0) {
      decorationCol.remove();
      decorationCol.insertBefore(prev);
      setOrderIndex(decorationCol);
      setOrderIndex(prev[0]);
      setupColMove(decorationCol);
    }
  }

  function onRightButtonClicked() {
    var decorationCol = $(this).closest('.decoration-col');
    var next = $(decorationCol).next();
    if ($(next).length > 0) {
      decorationCol.remove();
      decorationCol.insertAfter(next);
      setOrderIndex(decorationCol);
      setOrderIndex(next[0]);
      setupColMove(decorationCol);
    }
  }

  function setOrderIndex(decorationCol) {
    var index = $('.decoration-col').index(decorationCol);
    $(decorationCol).find('.decoration-order-index').val(index + 1);
  }

  function setupColMove(column) {
    $(column).find('.btn-left').click(onLeftButtonClicked);
    $(column).find('.btn-right').click(onRightButtonClicked);
  }

  var publicData = {
    setup: function() {
      $('.decoration-col').each(function() {
        setupColMove(this);
      });
    }
  };

  return publicData;
}());
