FashionLime.Merchant.Product.editArticles = (function() {
  'use strict';

  function calcPriceWithDiscount() {
    var row = $(this).closest('tr')
    
    var priceControl = row.find('.price')
    var percDiscControl = row.find('.perc_discount')
    var priceWithDiscountControl = row.find('.price_with_discount')

    FashionLime.Common.utils.calcPriceWithDiscount(priceControl, percDiscControl, priceWithDiscountControl);
  }

  var publicData = {
    setupCalcPriceWithDiscount: function() {
      $('.price').change(calcPriceWithDiscount);
      $('.perc_discount').change(calcPriceWithDiscount);
    }
  };

  return publicData;
}());
