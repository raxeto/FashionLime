FashionLime.Shared.dynamicFooter = (function() {
  'use strict';

  var ABOUT_BTN_ID = 'about-btn'

  function hideFooter() {
    if (!$('#footer').hasClass('dynamic-hidden')) {
      $('#footer').animate({ "bottom": "-1000px" }, "slow");
      $('#footer').addClass('dynamic-hidden');
    }
  }

  function onAllClicked(event) {
    if (!$.contains($('#footer')[0], event.target) && !$('#footer').is(event.target)) {
      hideFooter();
    }
  }

  function showFooter() {
    if ($('#footer').hasClass('dynamic-hidden')) {
      $('#footer').animate({ "bottom": "0px" }, "slow");
      $('#footer').removeClass('dynamic-hidden');
    }
  }

  function toggleFooter() {
    if ($('#footer').hasClass('dynamic-hidden')) {
      showFooter();
    } else {
      hideFooter();
    }
  }

  var publicData = {
    setup: function() {
      var btn = $('<a id="' + ABOUT_BTN_ID + '" class="sticky-left-btn" ' +
        'title="Информация за нас"><i class="fa fa-2x fa-info"></i></a>');

      $('body').append(btn);
      btn.click(toggleFooter);
      $('#footer').addClass('dynamic');
      $('#footer').addClass('dynamic-hidden');
      $('#footer').css("bottom", "-1000px");
      $('div#all').on('click', onAllClicked);
    },

    clear: function() {
      $('#' + ABOUT_BTN_ID).remove();
      $('#footer').removeClass('dynamic');
      $('#footer').removeClass('dynamic-hidden');
      $('div#all').off('click', onAllClicked);
    },

    // Hides the footer if it's dynamic
    hide: function() {
      if ($('#footer').hasClass('dynamic')) {
        hideFooter();
      }
    }
  };

  return publicData;
}());
