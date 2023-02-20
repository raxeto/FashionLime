(function() {
  'use strict';

  window.FashionLime.PaymentInfo.EpayInfo = function(merchantOrderId, htmlHolder) {
    this.htmlHolder = $(htmlHolder);
    this.code = null;
    this.merchantOrderId = merchantOrderId;
    this.askAttempts = 10;
    this.askInterval = 5000; // in milliseconds
    this.shouldStop = false;
  };

  FashionLime.PaymentInfo.EpayInfo.prototype = {

    startAskingForCode: function() {
      this.htmlHolder.find('.code-container').hide();
      this.htmlHolder.find('.error-container').hide();
      this.htmlHolder.find('.still-asking-container').show();
      this.shouldStop = false;
      this.askAttempts = 10;
      this.ask();
    },

    ask: function() {
      var that = this;
      function onResponse(response) {
        if (response && response.payment_code) {
          that.code = response.payment_code;
          that.shouldStop = true;
          that.showCode();
        } else if (response && !response.status) {
          if (response.error_code === "not_found") {
            that.showError('Нямате достъп до информацията за тази поръчка. Да не би да сте забравили да влезете в системата?');
          } else if (response.error_code === "epay_error") {
            that.showEpayError();
          }
        } else if (!that.shouldStop) {
          that.askAttempts--;
          if (that.askAttempts > 0) {
            setTimeout(that.ask.bind(that), that.askInterval);
          } else {
            console.log('Failed to retrieve epay code.');
            that.showEpayError();
          }
        }
      }

      FashionLime.Common.webApi.getEpayCode(this.merchantOrderId, onResponse);
    },

    showError: function(errorText) {
      this.htmlHolder.find('.error-container').text(errorText);
      this.htmlHolder.find('.error-container').show();
      this.htmlHolder.find('.still-asking-container').hide();
      this.htmlHolder.find('.code-container').hide();
    },

    showEpayError: function() {
      this.showError('Съжаляваме, но в момента не можем да осъществим връзка със системата на ePay.bg. '
                + 'Веднага щом връзката бъде осъществена, ще получите e-mail с кода за плащане.');
    },

    showCode: function() {
      this.htmlHolder.find('.code-holder').text(this.code);
      this.htmlHolder.find('.code-container').show();
      this.htmlHolder.find('.still-asking-container').hide();
      this.htmlHolder.find('.error-container').hide();
    },

    stopAskingForCode: function() {
      this.shouldStop = true;
    },

    hasCode: function() {
      return !!this.code;
    },

    cleanup: function() {
      if (!this.hasCode()) {
        this.stopAskingForCode();
      }
    },

    loadedFromCache: function() {
      if (!this.hasCode()) {
        this.startAskingForCode();
      }
    }
  };

}());
