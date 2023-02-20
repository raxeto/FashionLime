FashionLime.Merchant.SizeChart.form = (function() {
  'use strict';

  function onSizeCategoryChanged() {
    var sizeCategoryID = $(this).val();
    var name = $('#sizeChartName').val();
    var note = $('#sizeChartNote').val();
    var activation = $('#activation').val();
    var url = FashionLime.Common.utils.getBaseUrl() + '/merchant/size_charts/new';
    if (sizeCategoryID) {
      url += ("?size_category=" + sizeCategoryID + '&name=' +
          encodeURIComponent(name) + '&note=' + encodeURIComponent(note));
      if (activation) {
        url += "&activation=true";
      }
      // A trick to force the browser to use UTF-8.
      url += '&utf8=' + encodeURIComponent('✓');
      window.location.href = url;
    } else {
      deleteChart();
    }
  }

  function onDestroyClicked() {
    var row = $(this).closest('tr');
    var chartId = $('#size_chart_id').val();
    var sizeId = row.find('.size_id').val();
    if (confirm('Сигурни ли сте, че искате да изтриете този размер от таблицата?') === true) {
      if (chartId) {
        var params = {
           'id': chartId,
           'size_id': sizeId
        };
        FashionLime.Common.net.sendDeleteRequest('/merchant/size_charts/destroy_item.json', params,
          onDestroyResponse.bind(row));
      } else {
        $(row).remove();
      }
    }
  }

  function onDestroyResponse(response) {
    if (response.status) {
      $(this).remove();
      FashionLime.Common.notifications.clear();
      FashionLime.Common.notifications.notify('Успешно изтриване.');
    } else {
      FashionLime.Common.notifications.clear();
      FashionLime.Common.notifications.alert(response);
    }
  }

  function deleteChart() {
    $('#chartHolder').empty();
    $('#startSelectionPanel').show();
    $('#instructionsPanel').hide();
  }

  var publicData = {
    setupSizeCategoryChange: function() {
      $('#sizeCategoryID').change(onSizeCategoryChanged);
    },
    setupDestroy: function() {
      $('.btn-destroy').click(onDestroyClicked);
    },
    setupVisiblePanels: function() {
      if ($('#sizeCategoryID').val()) {
        $('#startSelectionPanel').hide();
        $('#instructionsPanel').show();
      } else {
        $('#startSelectionPanel').show();
        $('#instructionsPanel').hide();
      }
    }
  };

  return publicData;
}());
