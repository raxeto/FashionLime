FashionLime.Merchant.Shipment.index = (function() {
  'use strict';

  function null_new_control() {
    var table = document.getElementById("table_new_shipment");

    var children = table.getElementsByTagName('*');
    var len = children.length;

    var new_prefix = "new_shipment_";

    for (var i = 0; i < len; ++i) {
      var control = children[i];
      var id = control.id;

      if (id && id.startsWith(new_prefix)) {
        if (id === new_prefix + "period_from" || id === new_prefix + "period_to" ||
            id === new_prefix + "price" || id === new_prefix + "min_order_price") {
          control.value = 0;
        }
        else if (id === new_prefix + "period_type") {
          control.selectedIndex = 0;
        }
        else {
          control.value = null;
        }
      }
    }
  }

  function increase_newly_added() {
     change_newly_added(1);
  }

  function decrease_newly_added() {
      change_newly_added(-1);
  }

  function get_newly_added() {
    return parseInt(document.getElementById("_newly_added_rows").value);
  }

  function get_existing_rows() {
    return parseInt(document.getElementById("_existing_rows").value)
  }

  function change_newly_added(change) {
    var element = document.getElementById("_newly_added_rows");
    var newRows = parseInt(element.value);

    element.value = newRows + change;
  }

  function onShipmentDeleteResponse(childIndex, response) {
    if (response.status) {
      var row = $(this).closest('tr').remove();
      $('#merchant_merchant_shipments_attributes_' + childIndex + '_id').remove();
      FashionLime.Common.notifications.clear();
      FashionLime.Common.notifications.notify('Успешно изтриване.');
    } else {
      FashionLime.Common.notifications.clear();
      FashionLime.Common.notifications.alert(response);
    }
  }

  function validateEmptyNewFields() {
    var missingFields = [];
    if (FashionLime.Common.utils.isNullOrEmpty($('#new_shipment_name').val())) {
      missingFields.push("Наименование");
    }
    var periodFrom = parseInt($('#new_shipment_period_from').val());
    var periodTo = parseInt($('#new_shipment_period_to').val());
    if (periodFrom <= 0 || periodTo <= 0) {
      missingFields.push("Срок на доставка");
    }
    if (!$('#new_shipment_shipment_type_id').val()) {
      missingFields.push("Начин на доставка");
    }

    if (missingFields.length > 0) {
      alert("Моля попълнете " +  FashionLime.Common.utils.toSentence(missingFields));
      return false;
    }
    return true;
  }

  var publicData = {
     addShipment: function() {
        if (!validateEmptyNewFields()) {
          return;
        }

        var table = document.getElementById("table_shipments");
        var tableBody = table.getElementsByTagName('tbody')[0];

        var hiddenTemplateName = "template_row_index";
        var templateRowHidden = document.getElementById(hiddenTemplateName);
        var templateRow = templateRowHidden.parentNode;

        var templateRowIndex = parseInt(templateRowHidden.value);
        var index = get_existing_rows() + get_newly_added() + 1;

        increase_newly_added();

        var newRow = tableBody.appendChild(templateRow.cloneNode(true));
        newRow.style.display = ''

        var new_prefix = "new_shipment_";
        var templatePrefix = "merchant_merchant_shipments_attributes_"+templateRowIndex+"_";

        var newHiddenTemplate;

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

            var newID = id.replace("_"+templateRowIndex+"_", "_"+index+"_");
            var newName =  children[i].name.replace("["+templateRowIndex+"]", "["+index+"]");

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

    cancelAddShipment: function() {
      null_new_control();
      FashionLime.Shared.newRecord.hidePanel();
    },

    deleteShipment: function(button, id, childIndex){
      if (confirm('Сигурни ли сте, че искате да изтриете тази доставка?') === true) {
        if (id > 0) {
          var params = {
             'id': id
          };
          FashionLime.Common.net.sendDeleteRequest('/merchant/shipments/destroy_item.json', params,
            onShipmentDeleteResponse.bind(button, childIndex));
        } else {
          $(button.closest('tr')).remove();
        }
      }
      // delete the row
      // var row = button.parentNode.parentNode;
      // var table = document.getElementById("table_shipments");

      // table.deleteRow(row.rowIndex);

      // if (index >= 0) {
      //   var destroyInput = document.getElementById("merchant_merchant_shipments_attributes_"+index+"__destroy");
      //   destroyInput.value = true;
      // }
    }
  };

  return publicData;
}());
