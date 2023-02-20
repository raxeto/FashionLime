FashionLime.Common.net = (function() {
  'use strict';

  var publicData = {

    HTTP_CODES: {
      INTERNAL_SERVER_ERROR: 500,
      UNSUPPORTED_TYPE: 415,
      UNPROCESSABLE_ENTITY: 422,
      RECORD_NOT_FOUND: 404,
      FORBIDDEN: 403,
      REQUEST_ABORTED: 0
    },

    async: true,

    // TODO: Move to some other file and make it accessible fromt he outside
    disconnected: false,

    /**
     * Sends an asynchronous post request to the server.
     * @param {String} url
     * @param {JS Value} message
     * @param {Function} A callback that will be called with the server's HTTP response.
     * @type {jqXHR} the jQuery XHR object.
     */
    sendPostRequest: function(url, message, callback) {
      return sendRequest('post', url, message, callback, formatPostRequest, {});
    },

    /**
     * Sends an asynchronous get request to the server.
     * @param {String} url
     * @param {JS Value} message
     * @param {Function} A callback that will be called with the server's HTTP response.
     * @param {JS Value} ajaxOptions - optionos to override the ajax method
     * @type {jqXHR} the jQuery XHR object.
     */
    sendGetRequest: function(url, message, callback, ajaxOptions) {
      ajaxOptions = ajaxOptions || {};
      return sendRequest('get', url, message, callback, formatGetRequest, ajaxOptions);
    },

    /**
     * Sends an asynchronous delete request to the server.
     * @param {String} url
     * @param {JS Value} message
     * @param {Function} A callback that will be called with the server's HTTP response.
     * @type {jqXHR} the jQuery XHR object.
     */
    sendDeleteRequest: function(url, message, callback) {
      return sendRequest('DELETE', url, message, callback, formatPostRequest, {});
    },

    /**
     * Sends an asynchronous put request to the server.
     * @param {String} url
     * @param {JS Value} message
     * @param {Function} A callback that will be called with the server's HTTP response.
     * @type {jqXHR} the jQuery XHR object.
     */
    sendPutRequest: function(url, message, callback) {
      return sendRequest('PUT', url, message, callback, formatPostRequest, {});
    },

    /**
     * Sends an asynchronous patch request to the server.
     * @param {String} url
     * @param {JS Value} message
     * @param {Function} A callback that will be called with the server's HTTP response.
     * @type {jqXHR} the jQuery XHR object.
     */
    sendPatchRequest: function(url, message, callback) {
      return sendRequest('PATCH', url, message, callback, formatPostRequest, {});
    },

    /**
     * Sets the AJAX calls to run asynchronously (the default option).
     */
    asyncMode: function() {
      if (!this.async) {
        this.async = true;
        this.initJQueryAjax();
      }
    },

    /**
     * Sets the AJAX calls to run synchronously.
     * WARNING: Each ajax call will be blocking, after this mode is entered.
     */
    syncMode: function() {
      if (this.async) {
        this.async = false;
        this.initJQueryAjax();
      }
    },

    /**
     * @private initializes the jquery ajax api, giving it specific defaults.
     */
    initialize: function() {
      this.async = true;
      this.initJQueryAjax();
    },

    /**
     * @private Presets default options for all ajax requests, get and post.
     */
    initJQueryAjax: function() {
      $.ajaxSetup({
        dataType: 'json',
        headers: {
          Accept : "application/json; charset=utf-8",
          "Content-Type": "application/json; charset=utf-8"
        },
        jsonp: false,
        cache: false,
        timeout: 5000, // 5 sec
        async: publicData.async
      });
    },
  };

  /**
   * Formats the get message's data in an appropriate way for the backend to receive it.
   */
  function formatGetRequest(message) {
    return message;
  }

  /**
   * Formats the post message's data in an appropriate way for the backend to receive it.
   */
  function formatPostRequest(message) {
    return JSON.stringify(message);
  }

  /**
   * @private Sends an asynchronous request to a server, using a specific method.
   * @param {String} sendMethod
   * @param {String} url
   * @param {JS Value} message
   * @param {Function} A callback that will be called with the server's HTTP response.
   * @param {Function} A function that will be used to encrypt the data.
   * @param {Boolean} A flag that indicates if the 1 request at a time logic should be enabled.
   * @param {Hash} Additional options that should be passed to the jQuery ajax method.
   * @param {Boolean} (OPTIONAL) true if maintenance mode should be ignored for this request.
   * @type {XHR}
   */
  function sendRequest(sendMethod, url, message, callback, encryptingFunction, ajaxOptions) {
    var onSuccess = function(data) {
      publicData.disconnected = false;
      if (callback) {
        callback(data);
      }
    };
    formatOptions(sendMethod, url, ajaxOptions);
    var encryptedMessage = encryptingFunction(message);
    var onFailure = null;
    var performSend = function() {
      ajaxOptions['data'] = encryptedMessage;
      ajaxOptions['success'] = onSuccess;
      return $.ajax(ajaxOptions).fail(onFailure);
    };

    var failCount = 0;
    onFailure = function(data, jqueryStatusText) {
      // If the problem is an internal server error, then fail the request permanently.
      if (data.status === publicData.HTTP_CODES.INTERNAL_SERVER_ERROR ||
          jqueryStatusText === 'abort' ||
          data.status === publicData.HTTP_CODES.RECORD_NOT_FOUND ||
          data.status === publicData.HTTP_CODES.FORBIDDEN) {
        console.log('Request failed with code ' + data.status  + ' ' + jqueryStatusText)
        onSuccess(null);
        return;
      }

      if (data.status === publicData.HTTP_CODES.UNSUPPORTED_TYPE) {
        // JSON parsing failed. Encrypt and send again.
        encryptedMessage = encryptingFunction(message);
      }

      failCount++;

      if (failCount > 5) {
        // We have exceeded the second treshold, use a huge timeout to reduce the load.
        // setTimeout(performSend, 15000);
        if (callback) {
          callback(null);
        }
      } else if (failCount > 2) {
        // Set the state to disconnected.
        publicData.disconnected = true;

        // We have exceeded the first treshold, use timeout to reduce the load.
        setTimeout(performSend, 5000);
      } else {
        // Try resending without any timeouts or modifications.
        performSend();
      }
    };

    return performSend();
  }

  /**
   * @private Sets up the method and url to the ajax options.
   * @param {String} sendMethod
   * @param {String} url
   * @param {Hash} ajaxOptions
   */
  function formatOptions(sendMethod, url, ajaxOptions) {
    ajaxOptions['type'] = sendMethod.toUpperCase();
    ajaxOptions['url'] = url;
  }

  publicData.initialize();

  return publicData;
}());
