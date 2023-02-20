FashionLime.Product.utils = (function() {
  'use strict';

  var totalWithDiscountChangedEvent;

  function onSelectedColorChanged(productContainer, productId, setPrices) {
    publicData.loadSizesForColor(productContainer, productId, setPrices);
  }

  function onSelectedSizeChanged(productContainer, setPrices) {
    if (setPrices) {
      setPrice(productContainer);
    }
  }

  function setPrice(productContainer) {
    var pricesContainer = getPricesContainer(productContainer);
    var selected = getSelectedSize(productContainer);
    if (selected.val()) {
      var price = FashionLime.Common.utils.parseFloat(selected.attr("data-price"));
      var priceWithDiscount = FashionLime.Common.utils.parseFloat(selected.attr("data-price-with-discount"));

      $(pricesContainer).find('.price').text(FashionLime.Common.utils.toCurrency(price));
      $(pricesContainer).find('.price_with_discount').text(FashionLime.Common.utils.toCurrency(priceWithDiscount));

      if (Math.abs(price - priceWithDiscount) >= 0.005) {
        $(pricesContainer).find('.price').show();
      } else {
        $(pricesContainer).find('.price').hide();
      }

      var totalWithDiscount = getTotalWithDiscountContainer(productContainer);
      if (totalWithDiscount.length) {
        publicData.setTotalWithDiscount(productContainer);
      }

      $(pricesContainer).find('.general_price').hide();
      $(pricesContainer).find('.article_price').show();
    }
    else {
      $(pricesContainer).find('.general_price').show();
      $(pricesContainer).find('.article_price').hide();
    }
  }

  function getSelectedColor(productContainer) {
    return $(productContainer).find('.color_id option:checked');
  }

  function getSelectedSize(productContainer) {
    return $(productContainer).find('.size_id option:checked');
  }

  function getPricesContainer(productContainer) {
    return $(productContainer).find('.prices_container');
  }

  function getTotalWithDiscountContainer(productContainer) {
    return $(productContainer).find('.total_with_discount')
  }

  function setSizeOptionEnabled(option, enabled){
    var isEnabled = $(option).attr("disabled") !== "disabled";
    if (enabled && !isEnabled) {
      // Enable
      $(option).removeAttr("disabled");
      var text = $(option).text();
      var dashInd = text.indexOf('-');
      if (dashInd > -1) {
        text = FashionLime.Common.utils.trim(text.substring(0, dashInd));
      }
      $(option).text(text);
    } else if (!enabled && isEnabled) {
      // Disable
      $(option).attr("disabled", "disabled");
      var text = $(option).text() + " - не е наличен в избрания цвят";
      $(option).text(text);
    }
  }

  var publicData = {
    setupColorSelect: function(productContainer, productId, setPrices) {
      $(productContainer).find('.color_id').change(onSelectedColorChanged.bind(
        this, productContainer, productId, setPrices));
    },

    setupSizeSelect: function(productContainer, setPrices) {
      $(productContainer).find('.size_id').change(onSelectedSizeChanged.bind(
        this, productContainer, setPrices));
    },

    setupTotalChangedEvent: function(productContainer, changeEvent) {
      totalWithDiscountChangedEvent = changeEvent.bind(this, productContainer);
    },

    loadSizesForColor: function(productContainer, productId, setPrices) {
      var onResponse = function(response) {
        if (!response || response.status === false) {
          return;
        }
        var select = $(productContainer).find('.size_id');
        $(select).find('option').each(function() {
          if ($(this).val()) {
            setSizeOptionEnabled(this, false);
          }
        });
        var checked = false;
        for(var i = 0; i < response.length; ++i) {
          var matched = $(select).find('option[value=' + response[i].size_id + ']');
          setSizeOptionEnabled(matched, true);
          matched.attr('data-price', response[i].price);
          matched.attr('data-price-with-discount', response[i].price_with_discount);
          checked = checked || matched.is(':selected');
        }
        if (!checked) {
          $(select).find('option').prop("selected", false);
        }
        if (setPrices) {
          setPrice(productContainer);
        }
      };

      var selected = getSelectedColor(productContainer);
      var id = selected.attr('value');
      FashionLime.Common.net.sendGetRequest('/produkti/' + productId +
      '/sizes_for_color', {color: id}, onResponse);
    },

    setTotalWithDiscount: function(productContainer) {
      var totalContainer = getTotalWithDiscountContainer(productContainer);
      var selected = getSelectedSize(productContainer);
      var priceWithDiscount = selected.attr("data-price-with-discount");
      var qty = FashionLime.Common.utils.parseFloat($(productContainer).find('.qty').val());
      var totalWithDiscount = FashionLime.Common.utils.roundFloat(qty * FashionLime.Common.utils.parseFloat(priceWithDiscount), 2);
      $(totalContainer).text(FashionLime.Common.utils.toCurrency(totalWithDiscount));
      if (totalWithDiscountChangedEvent !== undefined) {
        totalWithDiscountChangedEvent();
      }
    }
  };

  return publicData;
}());
