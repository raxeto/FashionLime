(function() {
  'use strict';

  FashionLime.Cart.Show = function(items) {
    this.items = items;
  };

  FashionLime.Cart.Show.prototype = {
    init: function() {
      var that = this;
      $('.qty_field').keydown(function(e) {
        if (e.keyCode === 13) {
          that.updateCartDetail(this);
        }
      });
      $('.qty_field').change(function() {
        that.updateCartDetail(this);
      });
      $('.delete_qty_button').click(deleteCartDetail);
      return this;
    },

    updateTotal: function(itemId, newTotal) {
      var totalPrice = 0;
      for (var i = 0; i < this.items.length; ++i) {
        if (this.items[i].id === itemId) {
          this.items[i].total = newTotal;
        }
        totalPrice += parseFloat(this.items[i].total);
      }

      $('.total-items-price').text(FashionLime.Common.utils.toCurrency(totalPrice));
      $('#item-' + itemId + '-total').text(FashionLime.Common.utils.toCurrency(newTotal));
    },

    onQtyUpdateResponse: function(cartDetailId, response) {
      FashionLime.Common.notifications.clear();
      if (!response.status) {
        FashionLime.Common.notifications.alert(response);
      } else {
        FashionLime.Common.notifications.notify(
          'Съдържанието на Вашата количка беше променено успешно!');
        this.updateTotal(cartDetailId, response.new_total);
      }
    },

    updateCartDetail: function(el) {
      // Make an RPC to update the qty
      var cartDetailId = parseInt(el.name);
      var qtyStr = $(el).val();
      var qty = parseInt(qtyStr);
      if (FashionLime.Common.utils.isValidNumber(qtyStr) &&
          !FashionLime.Common.utils.isNaN(qty) && qty > 0) { // check for 0 or NaN
        var params = {
          'cart': {
            'cart_details_attributes': {
              'id': cartDetailId,
              'qty': qty
            }
          }
        };
        FashionLime.Common.net.sendPatchRequest('/cart/update.json', params,
          this.onQtyUpdateResponse.bind(this, cartDetailId));
      } else {
        alert('Въвели сте невалидна стойност за количество.');
      }
    }
  };

  // Private methods.

  function onQtyDeleteResponse(response) {
    if (!response.status) {
      FashionLime.Common.notifications.clear();
      FashionLime.Common.notifications.alert(response);
    } else {
      location.reload(true);
    }
  }

  function deleteCartDetail() {
    // RPC to the server to delete the detail.
    var cartDetailId = this.name;
    var params = {
        'cart': {
          'cart_details_attributes': {
            'id': cartDetailId,
          }
        }
      };
    if (confirm('Сигурни ли сте, че искате да изтриете продукта от количката?') === true) {
      FashionLime.Common.net.sendDeleteRequest('/cart/destroy_item.json', params,
        onQtyDeleteResponse);

      // delete the row
      var row = $(this).closest('tr').remove();
    }
  }

}());
