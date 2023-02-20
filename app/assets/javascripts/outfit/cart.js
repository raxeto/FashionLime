FashionLime.Outfit.cart = (function() {
  'use strict';

  function onProductQtyChanged(productContainer) {
    FashionLime.Product.utils.setTotalWithDiscount(productContainer);
  }

  function onDeleteProductClicked(productContainer) {
    $(productContainer).remove();
    setTotal();
  }

  function setTotal() {
    var total = 0.0;
    $('.product_container').each(function() { 
      var totalContainer = $(this).find('.total_with_discount');
      if (totalContainer.length > 0) {
        total += FashionLime.Common.utils.parseFloat(totalContainer.text());
      }
    });
    $('#all_products_total').text(FashionLime.Common.utils.toCurrency(total));
  }

  var publicData = {
    setupQtyChange: function(productContainer) {
      $(productContainer).find('.qty').change(onProductQtyChanged.bind(this, productContainer));
    },
    setupDeleteProduct: function(productContainer) {
      $(productContainer).find('.delete_product_button').click(onDeleteProductClicked.bind(this, productContainer));
    },
    onTotalChanged: function(productContainer) {
      setTotal();
    }
  };

  return publicData;
}());
