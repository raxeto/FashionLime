FashionLime.Order.new = (function() {
  'use strict';

  function onSelectedUserAddressChanged() {
    var selected    = $(this).find('option:checked');
    if (selected.val() === '') {
      return;
    }
    var locationId  = selected.attr('data-location-id');
    var settlementName  = selected.attr('data-settlement-name');
    var description = selected.attr('data-description');

    getForm().find('#order_address_attributes_location_suggestion').typeahead('val', settlementName);
    getForm().find("#order_address_attributes_location_id").val(locationId);
    getForm().find('#order_address_attributes_description').val(description);
  }

  function onMerchantShipmentChanged() {
    var container = getMerchantOrderContainer(this);
    var selected = $(container).find(".merchant-shipment-radio:checked");
    var newPrice = 0.0;
    if (selected.val()) {
      newPrice = FashionLime.Common.utils.parseFloat(selected[0].getAttribute('data-price'));
    } 

    $(container).find('.shipment_price').val(FashionLime.Common.utils.toCurrency(newPrice));
    recalcMerchantOrderTotals(getMerchantOrderContainer(this));

    setPaymentOptionsEnabled(container, true);
  }

  function onDetailDeleted() {
    var container = getMerchantOrderContainer(this);
    $(this).closest('tr').remove();
    if (noMoreMerchantOrderDetails(container)) {
      container.remove();
      recalcOrderTotal();
      setInvoiceMessagesVisibility();
    } else {
      recalcMerchantOrderDetailsTotals(container);
      setShipmentOptionsEnabled(container);  
    }
  }

  function onDetailQtyChanged() {
    var container = getMerchantOrderContainer(this);
    recalcMerchantOrderDetailsTotals(container);
    setShipmentOptionsEnabled(container);
  }

  function noMoreMerchantOrderDetails(container) {
    return $(container).find('.detail_price_with_discount').length === 0
  }

  function recalcMerchantOrderDetailsTotals(container) {
    var sum = 0.0;
    $(container).find('.detail_total_with_discount').each(function() {
      var detailContainer = $(this).closest('tr');
      var price = FashionLime.Common.utils.parseFloat($(detailContainer).find('.detail_price_with_discount').val()) || 0.0;
      var qty = FashionLime.Common.utils.parseFloat($(detailContainer).find('.detail_qty').val()) || 0.0;
      $(this).val(FashionLime.Common.utils.toCurrency(price * qty));
    });

    recalcMerchantOrderTotals(container);
  }

  function recalcMerchantOrderTotals(container) {
    var sum = 0.0;
    var shipmentPrice = FashionLime.Common.utils.parseFloat($(container).find('.shipment_price').val());

    $(container).find('.detail_total_with_discount').each(function() {
      sum += FashionLime.Common.utils.parseFloat($(this).val());
    });

    $(container).find('.header_total_with_discount').val(FashionLime.Common.utils.toCurrency(sum));
    $(container).find('.header_total_with_shipment').val(FashionLime.Common.utils.toCurrency(sum + shipmentPrice));

    recalcOrderTotal();
  }

  function recalcOrderTotal() {
    var sum = 0.0;
    getForm().find('.header_total_with_shipment').each(function() {
      sum += FashionLime.Common.utils.parseFloat($(this).val());
    });
    var productSum = 0.0;
    getForm().find('.header_total_with_discount').each(function() {
      productSum += FashionLime.Common.utils.parseFloat($(this).val());
    });
    var shipmentSum = 0.0;
    getForm().find('.shipment_price').each(function() {
      shipmentSum += FashionLime.Common.utils.parseFloat($(this).val());
    });

    getForm().find('#order_total_with_shipment').val(FashionLime.Common.utils.toCurrency(sum));
    getForm().find('#order_total_with_discount').val(FashionLime.Common.utils.toCurrency(productSum));
    getForm().find('#order_total_shipment').val(FashionLime.Common.utils.toCurrency(shipmentSum));
  }

  function setShipmentOptionsEnabled(container) {
    var orderTotal = FashionLime.Common.utils.parseFloat($(container).find('.header_total_with_discount').val()) || 0.0;
    $(container).find('.merchant-shipment-radio').each(function() {
      if ($(this).val()) {
        var shipmentMinOrderPrice = FashionLime.Common.utils.parseFloat($(this).attr('data-min-order-price'));
        var enabled = (shipmentMinOrderPrice <= orderTotal);
        setRadioEnabled(this, enabled);
        setMinOrderRemainMessage(this, shipmentMinOrderPrice, orderTotal);
        if (!enabled && $(this).is(':checked')) {
          $(this).prop("checked", false);
          $(this).change(); // Changed event does not occur when the value is changed from java script
        }
      }
    });
  }

  function setMinOrderRemainMessage(radioButton, shipmentMinOrderPrice, orderTotal) {
    var messageContainer = $(radioButton).parents('.order-option-table').find('.min-order-remain-price-message');
    if (shipmentMinOrderPrice <= orderTotal) {
      messageContainer.hide();
      messageContainer.text("");
    } else {
      messageContainer.show();
      messageContainer.text(FashionLime.Common.utils.format("Пазарувайте за още {0} от този търговец, за да се възползвате от тази доставка.", FashionLime.Common.utils.toCurrency(shipmentMinOrderPrice - orderTotal)));
    }
  }

  function setPaymentOptionsEnabled(container, selectDefaultPayment) {
    var selectedShipment = $(container).find(".merchant-shipment-radio:checked");
    var shipmentPayment = "0";
    var shipmentPaymentName = "";
    if (selectedShipment.val()) {
      shipmentPayment = selectedShipment.attr('data-payment-type-id');
      shipmentPaymentName = selectedShipment.attr('data-payment-type-name');
    }
    $(container).find(".merchant-payment-radio").each(function() {
      if ($(this).val()) {
        var enabled = shipmentPayment === "0" || shipmentPayment === $(this).attr('data-payment-type-id');
        setRadioEnabled(this, enabled);
        if (!enabled && $(this).is(':checked')) {
          $(this).prop("checked", false);
        }
      }
    });

    prepareDefaultPaymentType(container, shipmentPayment, shipmentPaymentName, selectDefaultPayment);
  }

  function prepareDefaultPaymentType(container, shipmentPayment, shipmentPaymentName, selectDefaultPayment) {
    var warning = $(container).find('.one-payment-available-warning');
    warning.hide();
    if (shipmentPayment === "0") {
      return;
    }
    var paymentOptions = $(container).find(".merchant-payment-radio");
    $(paymentOptions).each(function() {
      if (shipmentPayment === $(this).attr('data-payment-type-id')) {
       if ($(paymentOptions).length > 1) {
          warning.text("* избраната доставка изисква плащане " + shipmentPaymentName);
          warning.show();
        }
        if (!$(this).is(':checked') && selectDefaultPayment) {
          $(this).prop("checked", true);
        }
      } 
    });
  }

  function onIssueInvoiceChanged() {
    setInvoiceMessagesVisibility();
  }

  function setInvoiceMessagesVisibility() {
    var checked = $('#order_issue_invoice').is(':checked');
    if (checked) {
      $('.issue-invoice-messages').show();
      if (getMerchantOrdersCount() > 1) {
        $('.more-than-one-order-message').show();
      } else {
        $('.more-than-one-order-message').hide();
      }
    } else {
      $('.issue-invoice-messages').hide();
    }
  }

  function getForm() {
    return $('#order-form');
  }

  function getMerchantOrderContainer(el) {
    return $(el).closest("[name='merchant_order_container']");
  }

  function getAllMerchantOrderContainers() {
    return getForm().find("[name='merchant_order_container']");
  }

  function getMerchantOrdersCount() {
    return getAllMerchantOrderContainers().length;
  }

  function setRadioEnabled(radioButton, enabled) {
    if (enabled) {
      $(radioButton).removeAttr("disabled");
      $(radioButton).parents("div.order-option-container").removeClass("disabled");
    }
    else {
      $(radioButton).attr("disabled", "disabled");
      $(radioButton).parents("div.order-option-container").addClass("disabled");
    }
  }

  var publicData = {
    setAllOrdersShipmentOptionsEnabled: function() {
      getAllMerchantOrderContainers().each(function() {
        setShipmentOptionsEnabled(this);
      });
    },

    setAllOrdersPaymentOptionsEnabled: function() {
      getAllMerchantOrderContainers().each(function() {
        setPaymentOptionsEnabled(this, false);
      });
    },

    setupUserAddressSelect: function() {
      getForm().find('#order_user_address_id').change(onSelectedUserAddressChanged);
    },

    setupMerchantShipmentChange: function() {
      getForm().find('.merchant-shipment-radio').change(onMerchantShipmentChanged);
    },

    setupDetailDelete: function() {
      getForm().find('.delete_detail_button').click(onDetailDeleted);
    },

    setupQtyChange: function() {
      getForm().find('.detail_qty').change(onDetailQtyChanged);
    },

    setupIssueInvoiceChange: function() {
      getForm().find('#order_issue_invoice').change(onIssueInvoiceChanged);
    },

    setup: function() {
      publicData.setupMerchantShipmentChange();
      publicData.setAllOrdersShipmentOptionsEnabled();
      publicData.setAllOrdersPaymentOptionsEnabled();
      publicData.setupUserAddressSelect();
      publicData.setupQtyChange();
      publicData.setupDetailDelete();
      publicData.setupIssueInvoiceChange();
      setInvoiceMessagesVisibility();
    }
  };

  return publicData;
}());
