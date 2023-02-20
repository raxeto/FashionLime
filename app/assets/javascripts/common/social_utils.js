FashionLime.Common.socialUtils = (function() {
  'use strict';

  var publicData = {
    /**
     * Open a facebook share dialog for the current page.
     */
    openFbShareDialog: function(callback) {
      fbAsyncRun(function() {
        callback = callback || function(response) {
          console.log(response);
        };

        return FB.ui({
          method: 'share',
          href: FashionLime.href + location.pathname
        }, callback);
      });
    },

    /**
     * Initializes all Facebook share buttons on the page. By convention, they
     * are defined by the classes "external" and "facebook". For personal
     * facebook href links (like the links to the creators' accounts), add
     * class "personal" so that we don't add share logic to them.
     */
    initFbShareButtons: function(callback) {
      var el = $('.external.facebook').not('.bound').not('.personal');
      if (!el) {
        return;
      }

      el.click(function(event) {
        publicData.openFbShareDialog(callback);
        return false;
      });

      // Mark the already bound elements, so that we don't bind twice.
      el.addClass('bound');
    },

    /**
     * Makes an RPC call to the FB API to get the number of likes, shares and
     * comments for the given URL. If no URL is passed, then uses the current URL.
     * @param {OPTIONAL String} url
     * @param {OPTIONAL Function} callback - a function that takes
     *   (shareCount, likeCount, commentCount) as params.
     * @type {XHR}
     */
    getFbSharesCount: function(url, callback) {
      url = url || FashionLime.href + location.pathname;
      function cb(response) {
        console.log(response);
        if (callback && response) {
          callback(response['share_count'], response['like_count'],
              response['comment_count']);
        }
      }

      var data = {
        query: 'select like_count, share_count, comment_count from link_stat where url=\''
            + url + '\'',
        format: 'json'
      };

      return FashionLime.Common.net.sendGetRequest(
          'https://api.facebook.com/method/fql.query?callback=?',
          data, cb, { jsonp: true });
    }
  };

  return publicData;
}());




