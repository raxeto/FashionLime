FashionLime.Merchant.PaymentType.activation = (function() {
  'use strict';

  function onPaymentAnswerChanged() {
    var payment = $(this).closest(".payment");
    var paymentInfo = $(payment).find(".payment-info");
    if (paymentInfo.length > 0) {
      if (paymentInfo.hasClass("active")) {
        paymentInfo.removeClass("active");
      } else {
        paymentInfo.addClass("active");
      }
    }
  }

  var publicData = {
    setup: function() {
      $('.answer').change(onPaymentAnswerChanged);
    }
  };

  return publicData;
}());
