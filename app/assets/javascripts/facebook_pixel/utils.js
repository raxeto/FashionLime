FashionLime.FacebookPixelUtils = (function() {
  'use strict';

  var publicData = {
    trackPageview: function() {
      fbq('trackCustom', 'TurbolinksPageView', {
        url: window.document.location.href
      });
    },

    trackViewProduct: function(productId, price) {
      fbq('track', 'ViewContent', {
        content_type: 'product',
        content_ids: [productId],
        value: price,
        currency: 'BGN'
      });
    },

    trackViewProductCategory: function(categoryKey) {
      fbq('trackCustom', 'ViewProductCategory', {
        key: categoryKey
      });
    },

    trackAddToCart: function(productIds, totalValue) {
     fbq('track', 'AddToCart', {
        content_type: 'product',
        content_ids: productIds,
        value: totalValue,
        currency: 'BGN'
      });
    },

    trackPurchase: function(productIds, totalValue) {
      fbq('track', 'Purchase', {
        content_type: 'product',
        content_ids: productIds,
        value: totalValue,
        currency: 'BGN'
      });
    }
  };

  return publicData;
}());

