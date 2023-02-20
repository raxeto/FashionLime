FashionLime.Shared.backToTopBtn = (function() {
  'use strict';

  var BACK_TO_TOP_BTN_ID = 'back-to-top-btn';
  var OFFSET = 1000;

  function setupBackToTop() {
    var btn = $('<a id="' + BACK_TO_TOP_BTN_ID + '" class="sticky-left-btn" ' +
        'title="Върни се в началото на страницата"><i class="fa fa-2x fa-home"></i></a>');
    btn.hide();
    $('body').append(btn);
    btn.click(scrollToTop);

    $(window).scroll(onScroll);
  }

  function onScroll() {
    if ($(window).scrollTop() <= OFFSET) {
      $('#' + BACK_TO_TOP_BTN_ID).hide();
    } else {
      $('#' + BACK_TO_TOP_BTN_ID).show();
    }
  }

  function scrollToTop() {
    FashionLime.Common.utils.scrollPageToTop();
    return false;
  }

  var publicData = {
    setup: function() {
      setupBackToTop();
    },

    clear: function() {
      $('#' + BACK_TO_TOP_BTN_ID).remove();
      $(window).unbind('scroll', onScroll);
    }
  };

  return publicData;
}());
