FashionLime.Common.webApi = (function() {
  'use strict';

  var publicData = {

    /**
     * Gets the next batch of items as json objects with thumb data.
     * @param {Hash} filterParams - filter the items with these
     * @param {Integer} offset - the offset from which to continue
     * @param {Function} callback
     * @type {XHR}
     */
    loadNextItemBatch: function(modelName, loadMoreUrl, filterParams, offset, count, callback) {
      filterParams['offset'] = offset;
      filterParams['count'] = count;
      return FashionLime.Common.net.sendGetRequest(loadMoreUrl + '.json', filterParams, function(response) {
        var products = [];
        if (response) {
          for (var i = 0; i < response[0].length; ++i) {
            products.push(JSON.parse(response[0][i]));
          }
        }
        callback(products);
      });
    },

    /**
     * Attempts to change the rating for a product/outfit.
     * @param {String} command - increase/decrease/invalidate
     * @param {Integer} id - the id of the model that is being rated
     * @param {String} modelType - the class name of the model to be rated.
     * @param {Function} callback
     * @type {XHR}
     */
    changeRating: function(command, id, modelType, callback) {
      var params = {
        id: id,
        model_type: modelType
      };

      return FashionLime.Common.net.sendPostRequest('/ratings/' + command + '.json',
          params, callback);
    },

    /**
     * Attempts to get the epay 10 digit payment code.
     * @param {String} orderNumber - the unique number of the order in our system
     * @param {Function} callback
     * @type {XHR}
     */
    getEpayCode: function(orderNumber, callback) {
      var params = {
        order_number: orderNumber,
      };

      return FashionLime.Common.net.sendGetRequest('/orders/epay_code.json', params, callback);
    },

    /**
     * Attempts to delete a product.
     * @param {Integer} productid - the id of the product that is to be deleted
     * @param {Function} callback
     * @type {XHR}
     */
    deleteProduct: function(product_id, callback) {
      return FashionLime.Common.net.sendDeleteRequest('/merchant/products/' + product_id + '.json',
          {}, callback);
    },

    checkOutfitPictureGenerated: function(outfitId, callback) {
      return FashionLime.Common.net.sendGetRequest("/outfits/" + outfitId + "/picture_present.json",
          {}, callback);
    }
  };

  return publicData;
}());
