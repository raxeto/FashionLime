FashionLime.Shared.chart = (function() {
  Chart.defaults.global.responsive = true;

  var predefinedColorsRGB = [
    "193,51,70",
    "49,23,45",
    "220,220,220",
    "68,68,82",
    "103,138,104",
    "49,112,143",
    "199,156,80",
    "247,236,113",
    "152,108,42",
    "214,82,127",
    "139,195,74",
  ];
  
  function prepareData(data, dimensions, totals, type) {
    var labels = {}, labelsArr = [], datasets = {}, labelsCnt = 0;
    for (var i = 0; i < data.length; ++i) {
      var row = data[i];
      
      var dim = dimensions[0];
      var dimVal = row[dim];
      if (FashionLime.Common.utils.isNullOrEmpty(dimVal)) {
        dimVal = "(not set)";
      }
      if (FashionLime.Common.utils.isUndefined(labels[dimVal])) {
        labels[dimVal] = labelsCnt; // Index
        labelsArr.push(dimVal)
        ++labelsCnt;
      }

      var datasetDimVal = dimensions.length > 1 ? row[dimensions[1]] : totals[0].label;
       if (FashionLime.Common.utils.isNullOrEmpty(datasetDimVal)) {
        datasetDimVal = "(not set)";
      }
      if (FashionLime.Common.utils.isUndefined(datasets[datasetDimVal])) {
        datasets[datasetDimVal] = [];
      }

      var totalVal = row[totals[0].key];
      datasets[datasetDimVal][labels[dimVal]] = totalVal; 
    }

    if (type === "line" || type === "bar") {
      var ret = {};
      ret.labels = labelsArr;
      ret.datasets = [];
      var dimCnt = 0;
      for (var k in datasets) {
        if (datasets.hasOwnProperty(k)) {
          var dataset = {
            label: k,
            data: datasets[k]
          };
          ret.datasets.push(dataset);
          ++dimCnt;
        }
      }
      return ret;
    } else if (type === "pie") {
      var ret = [];
      for (var i = 0; i < labelsArr.length; ++i) {
        ret.push({
          label: labelsArr[i],
          value: datasets[totals[0].label][i]
        });
      }
      return ret;      
    }
  }

  function setColors(type, chartData) {
    var datasets = type === "pie" ? chartData : chartData.datasets;
    for (var i = 0; i < datasets.length; ++i) {
      if (!FashionLime.Common.utils.isUndefined(predefinedColorsRGB[i])) {
        var dataset = datasets[i];
        var color = predefinedColorsRGB[i];
        if (type === "line") {
          dataset.fillColor = FashionLime.Common.utils.format("rgba({0},0.2)", color);
          dataset.strokeColor = FashionLime.Common.utils.format("rgba({0},1)", color);
          dataset.pointColor = FashionLime.Common.utils.format("rgba({0},1)", color);
          dataset.pointStrokeColor = "#fff";
          dataset.pointHighlightFill = "#fff";
          dataset.pointHighlightStroke = FashionLime.Common.utils.format("rgba({0},1)", color);
        } else if (type === "bar") {
          dataset.fillColor = FashionLime.Common.utils.format("rgba({0},0.5)", color);
          dataset.strokeColor = FashionLime.Common.utils.format("rgba({0},0.8)", color);
          dataset.highlightFill = FashionLime.Common.utils.format("rgba({0},0.75)", color);
          dataset.highlightStroke = FashionLime.Common.utils.format("rgba({0},1)", color);
        } else if (type === "pie") {
          dataset.color = FashionLime.Common.utils.format("rgba({0},0.5)", color);
          dataset.highlight = FashionLime.Common.utils.format("rgba({0},0.75)", color);
        }
      }
    }
  }

  function validateData(type, dimensions, totals, alertContainerID) {
    var alertMsg = "";
    if (type === "pie") {
      if (dimensions.length !== 1 || totals.length !== 1) {
        alertMsg = 'За да генерирате този тип графика е необходимо да изберете точно един суматор и точно едно обикновено поле.';
      }
    } else if (type === "line" || type === "bar") {
      if ((dimensions.length !== 1 && dimensions.length !== 2) || totals.length !== 1) {
        alertMsg = 'За да генерирате този тип графика е необходимо да изберете точно един суматор и едно или две обикновени полета.';
      }
    }

    var alert = $('#' + alertContainerID)
    if (alertMsg.length === 0) {
      alert.hide();
      return true;
    } else {
      alert.html(alertMsg);
      alert.show();
    }
  }

  function placeLegend(chart, legendContainerID) {
   
    var legendHtml = chart.generateLegend();
    $('#' + legendContainerID).html(legendHtml);
  }

  function createChartObject(canvasID, type, chartData) {
    var context = $("#" + canvasID).get(0).getContext("2d");
    var chart;
    if (type === "line") {
      options = { 
        legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><div class=\"color-square\" style=\"background-color:<%=datasets[i].strokeColor%>\"></div><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
      }
      chart = new Chart(context).Line(chartData, options);
    } else if (type === "bar") {
      options = { 
        legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><div class=\"color-square\" style=\"background-color:<%=datasets[i].fillColor%>\"></div><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
      }
      chart = new Chart(context).Bar(chartData, options);
    } else if (type === "pie") {
      options = { 
        legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><div class=\"color-square\" style=\"background-color:<%=segments[i].fillColor%>\"></div><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
      }
      chart = new Chart(context).Pie(chartData, options);
    }
    return chart;
  }

  var publicData = {
    create: function(canvasID, type, dimensions, totals, data, alertContainerID, legendContainerID) {
      var isValid = validateData(type, dimensions, totals, alertContainerID);
      if (!isValid) {
        return;
      }
      var chartData = prepareData(data, dimensions, totals, type);
      setColors(type, chartData);

      var chart = createChartObject(canvasID, type, chartData);
      placeLegend(chart, legendContainerID);
    }
  };

  return publicData;
}());
