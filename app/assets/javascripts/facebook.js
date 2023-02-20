(function() {
  'use strict';

  var functionQueue = [];

  window.fbAsyncInit = function() {
    FB.init({
      appId      : 'ххххх',
      xfbml      : true,
      version    : 'v2.6',
      //status     : true
    });

    for (var i = 0; i < functionQueue.length; ++i) {
      functionQueue[i]();
    }
    functionQueue = [];
  };

  // Use this function to run FB.<method> commands on page load without getting
  // errors. Usage:
  // fbAsyncRun(function() {
  //   FB.ui(params);
  // });
  window.fbAsyncRun = function(func) {
    if (window.FB) {
      func();
    } else {
      functionQueue.push(func);
    }
  };

  $(document).ready(function() {
    $.ajax({
      url: '//connect.facebook.net/bg_BG/sdk.js',
      dataType: "script",
      success: fbAsyncInit,
      async: true,
      cache: true
    });
  });
})();
