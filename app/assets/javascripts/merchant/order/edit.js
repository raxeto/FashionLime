FashionLime.Merchant.Order.edit = (function() {
  'use strict';

  function onMerchantShipmentChanged() {
    var selected = $(this).find("option:checked");
    var newPrice = 0.0;
    if (selected.val()) {
      var newPrice = FashionLime.Common.utils.parseFloat(selected[0].getAttribute('data-price'));
      $('.shipment_price').val(FashionLime.Common.utils.toCurrency(newPrice, true, false));
    }
    recalcMerchantOrderTotals();
  }

  function onStatusChanged() {
    if ($('#merchant_order_status').val() === "canceled") {
      $('.cancellation_note_row').show();
    } else {
      $('.cancellation_note_row').hide();
    }
  }

  function onShipmentPriceChange() {
    recalcMerchantOrderTotals();
  }

  function recalcMerchantOrderTotals() {
    var sum = 0.0;
    var shipmentPrice = FashionLime.Common.utils.parseFloat($('.shipment_price').val());

    $('.detail_total_with_discount').each(function() {
      sum += FashionLime.Common.utils.parseFloat($(this).text());
    });

    sum = FashionLime.Common.utils.roundFloat(sum);
    $('.header_total_with_discount').val(FashionLime.Common.utils.toCurrency(sum));
    $('.header_total_with_shipment').val(FashionLime.Common.utils.toCurrency(sum + shipmentPrice));
  }

  var publicData = {
    setupMerchantShipmentSelect: function() {
      $('.merchant_shipment_select').change(onMerchantShipmentChanged);
    },
    setupShipmentPriceChange: function() {
      $('.shipment_price').change(onShipmentPriceChange);
    },
    setupStatusSelect: function() {
      $('#merchant_order_status').change(onStatusChanged);
    },
    setup: function() {
      onStatusChanged();
      publicData.setupMerchantShipmentSelect();
      publicData.setupShipmentPriceChange();
      publicData.setupStatusSelect();
    }
  };

  return publicData;
}());
