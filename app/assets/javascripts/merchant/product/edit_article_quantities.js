(function() {
  'use strict';

  FashionLime.Merchant.Product.EditArticleQuantities = function() {
    FashionLime.Shared.newRecord.setup();
    $('#table_new_quantity .btn-add').click(this.addQuantity.bind(this));
    $('#table_new_quantity .btn-cancel').click(this.cancelAddNewArtQty.bind(this));
  };

  FashionLime.Merchant.Product.EditArticleQuantities.prototype = {
    addQuantity: function() {
      var new_prefix = "new_art_qty_";

      var artDropDown = document.getElementById(new_prefix + "article_id");
      var artID = parseInt(artDropDown.options[artDropDown.selectedIndex].value || 0);

      if (artID === 0) {
        alert('Моля изберете артикул.');
        return;
      }

      var qtyInput = document.getElementById(new_prefix + "qty");
      var qty = FashionLime.Common.utils.parseFloat(qtyInput.value) || 0.0;

      if (qty < 0.0005) { // Create a file with JS constants
        alert('Моля въведете количество по-голямо от нула.');
        return;
      }

      var artName = artDropDown.options[artDropDown.selectedIndex].text;

      var hiddenArtIndexName = "hidden_art_index_" + artID;
      var hiddenTemplateName = "template_art_id_"+artID+"_row_index";

      var templateRowHidden = document.getElementById(hiddenTemplateName);
      var templateRow = templateRowHidden.parentNode;

      var templateRowIndex = templateRowHidden.value;
      var index = get_existing_rows(artID) + get_newly_added(artID) + 1;

      var artIndex = document.getElementById(hiddenArtIndexName).value;

      increase_newly_added(artID);

      var tableBody = document.getElementById("table_quantities").getElementsByTagName('tbody')[0];

      var newRow = tableBody.appendChild(templateRow.cloneNode(true));
      newRow.style.display = ''

      var templatePrefix = "product_articles_attributes_" + artIndex + "_article_quantities_attributes_"+templateRowIndex+"_";

      var newHiddenTemplate = null;

      var children = newRow.getElementsByTagName('*');
      var len = children.length;

      for (var i = 0; i < len; ++i) {
        var id = children[i].id;

        if (id === hiddenTemplateName) {
          newHiddenTemplate = children[i];
        }

        if (id && id.startsWith(templatePrefix)){
          var inputName = id.replace(templatePrefix, new_prefix);
          var new_control = document.getElementById(inputName);

          if (new_control) {
            children[i].value = new_control.value;
          }

          var idPrefix = "product_articles_attributes_" + artIndex + "_article_quantities_attributes"
          var namePrefix = "product[articles_attributes][" + artIndex + "][article_quantities_attributes]"

          var newID = id.replace(idPrefix + "_"+templateRowIndex, idPrefix + "_"+index);
          var newName = children[i].name.replace(namePrefix + "["+templateRowIndex+"]", namePrefix + "["+index+"]");
          if (newID.indexOf("active") > -1) {
            for (var j = 0; j < children[i].parentNode.childNodes.length; ++j) {
              children[i].parentNode.childNodes[j].id = newID;
              children[i].parentNode.childNodes[j].name = newName;
            }
          } else {
            children[i].id = newID;
            children[i].name = newName;
          }
        }
      }

      // Remove template row marker
      newHiddenTemplate.parentNode.removeChild(newHiddenTemplate);

      FashionLime.Shared.newRecord.hidePanel();
      FashionLime.Shared.newRecord.addInsertWarning();

      null_new_control();
    },

    cancelAddNewArtQty: function() {
      null_new_control();
      FashionLime.Shared.newRecord.hidePanel();
    }
  };

   function onQuantityDeleteResponse(artIndex, qtyIndex, response) {
      if (response.status) {
        var row = $(this).closest('tr').remove();
        $('#product_articles_attributes_' + artIndex + '_article_quantities_attributes_' + qtyIndex + '_id').remove();
        FashionLime.Common.notifications.clear();
        FashionLime.Common.notifications.notify('Успешно изтриване.');
      } else {
        FashionLime.Common.notifications.clear();
        FashionLime.Common.notifications.alert(response);
      }
  }

  FashionLime.Merchant.Product.EditArticleQuantities.deleteQuantity = function(
        button, productId, qtyId, artIndex, qtyIndex) {
    if (confirm('Сигурни ли сте, че искате да изтриете това количество?') === true) {
      if (qtyId > 0) {
        var params = {
           'article_quantity_id': qtyId
        };
        FashionLime.Common.net.sendDeleteRequest('/merchant/products/'+productId+'/destroy_article_quantity.json', params,
          onQuantityDeleteResponse.bind(button, artIndex, qtyIndex));
      } else {
        $(button.closest('tr')).remove();
      }
    }
  };

   function increase_newly_added(artID) {
     change_newly_added(artID, 1);
   }

   function get_newly_added_input(artID) {
    return document.getElementById("art_id_"+artID+"_newly_added_rows");
   }

   function get_newly_added(artID) {
    return parseInt(get_newly_added_input(artID).value);
   }

   function change_newly_added(artID, change) {
      var element = get_newly_added_input(artID);
      var newRows = parseInt(element.value);

      element.value = newRows + change;
   }

   function get_existing_rows(artID) {
    return parseInt(document.getElementById("art_id_"+artID+"_existing_rows").value)
   }

   function null_new_control() {
      var table = document.getElementById("table_new_quantity");

      var children = table.getElementsByTagName('*');
      var len = children.length;

      var new_prefix = "new_art_qty_";

      for (var i = 0; i < len; ++i) {
        var control = children[i];
        var id = control.id;

        if (id && id.startsWith(new_prefix)) {
          if (id === new_prefix + "qty") {
            control.value = 0.0;
          }
          else if (id === new_prefix + "article_id") {
            control.selectedIndex = 0;
          }
          else {
            control.value = null;
          }
        }
     }
   }

}());
