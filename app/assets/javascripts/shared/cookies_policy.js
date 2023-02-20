FashionLime.Shared.cookiesPolicy = (function() {
  'use strict';

  var COOKIES_BANNER_SEEN_COOKIE = 'cookies-banner-seen';

  function mark_as_seen() {
    Cookies.set(COOKIES_BANNER_SEEN_COOKIE, 1, { expires: 36500 });
    $('#cookie-policy-banner').hide(600);
  }

  var publicData = {
    setup: function() {
      if (Cookies.get(COOKIES_BANNER_SEEN_COOKIE)) {
        // Cookies banner has already been seen and acknowledged
        return;
      }

      $('#cookie-policy-banner button').click(mark_as_seen);
      $('#cookie-policy-banner a').click(mark_as_seen);
      $('#cookie-policy-banner').show(800);
    }
  };

  return publicData;
}());