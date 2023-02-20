FashionLime.GoogleAnalyticsUtils = (function() {
  'use strict';

  function init() {
    if (!window.GoogleAnalytics) {
      window['GoogleAnalyticsObject'] = 'GoogleAnalytics';
      window.GoogleAnalytics = window.GoogleAnalytics || function() {
        (window.GoogleAnalytics.q = window.GoogleAnalytics.q || []).push(arguments);
      };
      window.GoogleAnalytics.l = 1 * new Date();
    }
  }

  function setUserID(userID) {
    window.GoogleAnalytics('set', 'userId', userID);
    window.GoogleAnalytics('set', 'dimension1', userID);
  }

  var publicData = {
    load: function() {
      init();
      var newScriptElement = document.createElement('script');
      var existingScriptElement = document.getElementsByTagName('script')[0];
      newScriptElement.async = 1;
      newScriptElement.src = '//www.google-analytics.com/analytics.js';
      existingScriptElement.parentNode.insertBefore(newScriptElement, existingScriptElement);

      // Create a tracker.
      window.GoogleAnalytics('create', 'UA-хххххх-1', 'auto');
    },

    trackPageview: function(userID, url) {
      if (userID) {
        setUserID(userID);
      }
      if (url) {
        window.GoogleAnalytics('send', 'pageview', url);
      } else {
        window.GoogleAnalytics('send', {
          hitType: 'pageview',
          location: document.location
        });
      }
    }
  };

  return publicData;
}());

