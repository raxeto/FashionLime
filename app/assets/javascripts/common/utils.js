FashionLime.Common.utils = (function() {
  'use strict';

  var publicData = {

    // Get the current url parameters and convert them to a json object.
    urlParamsAsJson: function() {
      if (location.search) {
        var search = location.search.substring(1);
        if (search) {
          return publicData.paramStrToJson(search);
        }
      }
      return {};
    },

    paramStrToJson: function(paramStr) {
      var res = {};
      var pairs = decodeURI(paramStr).split('&');

      for (var i = 0; i < pairs.length; ++i) {
        var split = pairs[i].split('=');
        var name = split[0];
        var value = split[1];
        if (name.indexOf('[]') !== -1) {
          var newName = name.replace('[]', '');
          if (!res[newName]) {
            res[newName] = [];
          }
          res[newName].push(value);
        } else {
          res[name] = value;
        }
      }

      return res;
    },

    // Encode the json object's values into the url as param pairs.
    jsonToUrlParams: function(params) {
      var urlParams = '?';
      for (var name in params) {
        if (params.hasOwnProperty(name)) {
          var value = params[name];
          if (publicData.isArray(value)) {
            for (var i = 0; i < value.length; ++i) {
              urlParams += name + escape('[]') + '=' + value[i];
              urlParams += '&';
            }
          } else {
            urlParams += name + '=' + value;
            urlParams += '&';
          }
        }
      }

      urlParams = urlParams.slice(0, -1);
      var url = location.href;
      var paramStart = url.indexOf('?');
      if (paramStart !== -1) {
        url = url.slice(0, paramStart);
      }

      url += urlParams;
      if (window.history && window.history.pushState) {
        window.history.pushState({ fashionLime: true }, document.title, url);
      } else if (urlParams) {
        location.replace(url);
      }
    },

    // Call this once at initialization time in order for jsonToUrlParams to behave
    // correctly on back button pressed.
    setupHistoryOnPopState: function() {
      window.onpopstate = function(event) {
        if(event && event.state && event.state.fashionLime) {
          // We did a history.pushState with a fake page, so we should
          // reload in order to show the page.
          location.reload();
        }
      }
    },

    // String format:
    // format("{0} is great but {1} is awesome", 'Joro', 'Rali')
    //  returns 'Joro is great but Rali is awesome'
    format: function(format) {
      var args = Array.prototype.slice.call(arguments, 1);
      return format.replace(/{(\d+)}/g, function(match, number) {
        return typeof args[number] != 'undefined' ? args[number] : match;
      });
    },

    // Filters all non digit characters from the string, leaving only a positive
    // integer.
    isValidNumber: function(str) {
      if (str) {
        // Filters all non digit characters, including the floating point and
        // strips any leading zeroes.
        return str.match(/^-?\d+\.?\d*$/g);
      }
      return false;
    },

    // Checks if a number is the NaN constant.
    isNaN: function(n) {
      return n !== n;
    },

    // Checks if an object is a string.
    isString: function(o) {
      return typeof o === 'string' || o instanceof String;
    },

    // Checks if an object is an array.
    isArray: function(o) {
      return o instanceof Array;
    },

    // Checks if the given value is a JS object.
    isObject: function(o) {
      return !publicData.isArray(o) && typeof o === 'object'
          && o !== null;
    },

    isUndefined: function(o) {
      return typeof o == 'undefined';
    },

    isNull: function(o) {
      return o === null
    },

    isNullOrEmpty: function(o) {
      return o === null || !(/\S/.test(o));
    },

    isUndefinedOrEmpty: function(o) {
      return publicData.isUndefined(o) || publicData.isNullOrEmpty(o);
    },

    // Trim the string
    trim: function(str) {
      return str.replace(/^\s+|\s+$/gm,'');
    },

    // Rounds to the second symbol after the decimal point
    roundFloat: function(n) {
      return +(Math.round(n + "e+2")  + "e-2");
    },

    // Parse float with thousands separator
    parseFloat: function(n) {
      return window.parseFloat(n.replace(' ', ''));
    },

    parseDate: function(dateStr) {
      // format for bg locale
      // the format from date_time_to_s
      var m = moment(dateStr, "DD MMMM YYYY, HH:mm", true);
      if (m.isValid()) {
        return m.toDate();
      }
      // the format from date_to_s
      m = moment(dateStr, "DD MMMM YYYY", true);
      if (m.isValid()) {
        return m.toDate();
      }
      // the format used for report's dates
      m = moment(dateStr, "DD-MM-YYYY", true);
      if (m.isValid()) {
        return m.toDate();
      }
      return null;
    },

    parseDateFromInput: function(dateStr) {
      // format for bg locale
      // used to parse when user enter value in some input
      // given format string will match DD MM YYYY, DD-MM-YYYY, DD.MM.YYYY, DD/MM/YYYY
      var m = moment(dateStr, "DD MM YYYY");
      if (m.isValid()) {
        return m.toDate();
      }
      return null;
    },

    // http://jsfiddle.net/hAfMM/612/
    // * @param integer d: length of decimal
    // * @param integer w: length of whole part
    // * @param mixed   s: sections delimiter
    // * @param mixed   c: decimal delimiter
    formatCurrency: function(number, n, x, s, c) {
      var re = '\\d(?=(\\d{' + (x || 3) + '})+' + (n > 0 ? '\\D' : '$') + ')',
          num = number.toFixed(Math.max(0, ~~n));

      return (c ? num.replace('.', c) : num).replace(new RegExp(re, 'g'), '$&' + (s || ','));
    },

    // TODO respect locals when new currency is available
    toCurrency: function(n, round, with_unit) {
      round = typeof round !== 'undefined' ? round : true;
      with_unit = typeof with_unit !== 'undefined' ? with_unit : true;
      if (round) {
        n = publicData.roundFloat(n);
      }
      var ret = publicData.formatCurrency(n, 2, 3, ' ', '.');
      if (with_unit) {
        ret += (' ' + publicData.currencySymbol());
      }
      return ret;
    },

    toCurrencyRange: function(n1, n2, round, with_unit) {
      with_unit = typeof with_unit !== 'undefined' ? with_unit : true;
      var ret = publicData.toCurrency(n1, round, false);
      if (Math.abs(n1 - n2) >= 0.005) {
        ret += (' - ' + publicData.toCurrency(n2, round, false));
      }
      if (with_unit) {
        ret += (' ' + publicData.currencySymbol());
      }
      return ret;
    },

    currencySymbol: function() {
      return 'лв.';
    },

    toSentence: function(words) {
      if (publicData.isNull(words) || words.length === 0) {
        return "";
      }
      if (words.length === 1) {
        return words[0];
      }
      return words.slice(0, -1).join(', ') + " и " + words[words.length - 1];
    },

    // Returns current url without any query parameters
    getPlainUrl: function(){
      var location = window.location;
      return [location.protocol, '//', location.host, location.pathname].join('');
    },

    getBaseUrl: function() {
      var location = window.location;
      return [location.protocol, '//', location.host].join('');
    },

    getTableRowsCount: function(table) {
      return $(table).find('tr').length;
    },

    // Explanations about events and turbolinks here - https://github.com/rails/turbolinks
    // redirect_to makes visit() which changes only the body (if the page is presented in the cache)
    // render changes the whole page
    // on initial page loading and whole page loading ready and page:change events are called
    // on redirect_to page:load and page:change events are called
    // when back button is pressed the page is taken from the turbolinks cache and there is no request to the server
    // when taken from the cache the page is not evaluated again - so any java script in the body is not called
    // however if there is a callbacks hooked to page:change event they are called
    // turbolinks cache again replace only the body

    // Call this with any JS setup method that should be executed once and only
    // once, after the page has fully loaded.
    onPageLoad: function(cb) {
      var setup = function() {
        // Be sure to clean up the method from the event queue.
        $(document).off('page:load', setup);
        $(document).off('ready', setup);
        cb();
      };

      $(document).on('page:load', setup);
      $(document).on('ready', setup);
    },

    // This callback will be called when Turbolinks serves a page from it's cache.
    // The typical flow is:
    // 1. onPageLoad - initial load of the page.
    // 2. onPageUnload - the user has navigated away from the page (back button pressed/link followed/url changed)
    // 3. onLoadFromCache - the user pressed back (forward) button pressed
    // 4. onPageUnload - the user has navigated away from the page (back button pressed/link followed/url changed)
    // ...
    // Arguments;
    // cb - the callback to be performed
    // el - a STRING selector for an element that MUST be visible, in order for
    //    the cb to be executed this is like a sanity check, otherwise we might
    //    call the cb when the page is actually in background.
    onLoadFromCache: function(cb, el) {
      $(function() {
        // Why the extra function block and the domEl var? Well if we pass a string
        // selector to the function, then it will check if any element with that
        // selector is visible, rather than the element from the current page.
        var domEl = $(el);
        var setup = function() {
          console.log('cache setup');
          if ($(domEl).is(":visible")) {
            console.log('cache restore');
            cb();
          }
        };

        $(document).on('page:restore', setup);
      });
    },

    // Call this with any JS cleanup method, that should clean up the state every
    // time before the user navigates away from the current page.
    // Arguments;
    // cb - the callback to be performed
    // el - a STRING selector for an element that MUST be visible, in order for
    //    the cb to be executed this is like a sanity check, otherwise we might
    //    call the cb when the page is actually in background.
    onPageUnload: function(cb, el) {
      $(function() {
        // Why the extra function block and the domEl var? Well if we pass a string
        // selector to the function, then it will check if any element with that
        // selector is visible, rather than the element from the current page.
        var domEl = $(el);
        var cleanup = function() {
          console.log('cleanup');
          if ($(domEl).is(":visible")) {
            console.log('doing cleanup');
            cb();
          }
        };

        $(document).on('page:before-unload', cleanup);
      });
    },

    // We have to set the keypress event on Enter key pressed
    // Because sometimes may happen that submit event is not fired on enter hit
    // https://api.jquery.com/submit/
    onFormSubmit: function(form, cb) {
      $(form).submit(function(event) {
        return cb(event);
      });
      $(form).keypress(function(event) {
        var key = event.which;
        if (key === 13) {
          if (!cb(event)) {
            event.preventDefault();
          }
        }
      });
    },

    // Undoes the onFormSubmit command.
    clearOnFormSubmit: function(form, cb) {
      $(form).off('submit', cb);
      $(form).off('keypress', cb);
    },

    // Check if an element is visible on the screen.
    checkIsVisible: function(elem) {
      if ($(elem).size() === 0 || !$(elem).offset()) {
        return false;
      }

      var vpH = $(window).height(); // Viewport Height
      var st = $(window).scrollTop(); // Scroll Top
      var y = $(elem).offset().top;
      var elementHeight = $(elem).height();

      return ((y < (vpH + st)) && (y > (st - elementHeight)));
    },

    // Check if the page is scrolled to the bottom.
    pageScrolledToBottom: function() {
      return $(window).scrollTop() + $(window).height() === $(document).height();
    },

    scrollPageToTop: function () {
      $("html, body").animate({ scrollTop: 0 }, 600);
    },

    // Shows the login modal on the screen. If warnMessage is passed, then its
    // value will fill the warning section of the modal and this warning will
    // be shown.
    showLoginModal: function(warnMessage) {
      if (warnMessage) {
        $('#login-modal-warn .warn-msg').text(warnMessage);
        $('#login-modal-warn').show();
      }
      $('#login-modal-btn').click();
    },

    fileNameFromFilePath: function(filePath) {
      return filePath.split(/(\\|\/)/g).pop();
    },

    calcPriceWithDiscount: function(priceControl, percDiscControl, priceWithDiscountControl) {
      var price = FashionLime.Common.utils.parseFloat($(priceControl).val());
      var percDiscount = FashionLime.Common.utils.parseFloat($(percDiscControl).val());
      $(priceWithDiscountControl).val(FashionLime.Common.utils.toCurrency(price * (100 - percDiscount)/100, true, true));
    },

    executeFunctionByName: function(functionName, context /*, args */) {
      var args = [].slice.call(arguments).splice(2);
      var namespaces = functionName.split(".");
      var func = namespaces.pop();
      for(var i = 0; i < namespaces.length; i++) {
        context = context[namespaces[i]];
      }
      return context[func].apply(context, args);
    },

    execModelPartial: function(modelPartial, model) {
      return publicData.executeFunctionByName(modelPartial + ".get", window, model);
    },

  };

  return publicData;
}());






