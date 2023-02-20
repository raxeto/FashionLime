FashionLime.Shared.bootstrapTable = (function() {
  $.fn.bootstrapTable.defaults.icons.export = 'fa fa-download';
  
  // pdf doesn't work - there is something more to add if you want to work
  // csv displays cyrillic wrong
  $.fn.bootstrapTable.defaults.exportTypes = ['excel', 'txt', 'doc', 'sql', 'xml', 'json'];

  // Fix in order filter to be case insensitive
  $.fn.bootstrapTableFilter.filterSources.search.check = function(filterData, value) {
      value = value.toUpperCase();

      if (typeof filterData.eq !== 'undefined' && value != filterData.eq.toUpperCase()) {
        return false;
      }
      if (typeof filterData.neq !== 'undefined' && value == filterData.neq.toUpperCase()) {
        return false;
      }
      if (typeof filterData.cnt !== 'undefined' && value.indexOf(filterData.cnt.toUpperCase()) < 0) {
        return false;
      }
      if (typeof filterData.ncnt !== 'undefined' && value.indexOf(filterData.ncnt.toUpperCase()) >= 0) {
        return false;
      }
      if (typeof filterData._values !== 'undefined' && filterData._values.indexOf('ept') >= 0 && value.trim()) {
        return false;
      }
      if (typeof filterData._values !== 'undefined' && filterData._values.indexOf('nept') >= 0 && !value.trim()) {
        return false;
      }
      return true;
  }

  // The bootstrap table filter "range" compares with parseInt so range filter is suitable for columns with integer data
  // Use "range_date" & "range_float" for date, datetime and float columns

  $.fn.bootstrapTableFilter.filterSources.range_date = {
    search: false,
    rows: $.fn.bootstrapTableFilter.filterSources.range.rows,
    check: function(filterData, value) {
      return checkRangeFilter(
        filterData, 
        value, 
        FashionLime.Common.utils.parseDate, 
        FashionLime.Common.utils.parseDateFromInput, 
        FashionLime.Common.utils.isNull,
        function(l, r) {
          return l.getTime() === r.getTime(); // DateTime objects !== & === are compared by reference
        });
    }
  }

  $.fn.bootstrapTableFilter.filterSources.range_float = {
    search: false,
    rows: $.fn.bootstrapTableFilter.filterSources.range.rows,
    check: function(filterData, value) {
      return checkRangeFilter(
        filterData, 
        value, 
        FashionLime.Common.utils.parseFloat, 
        FashionLime.Common.utils.parseFloat, 
        FashionLime.Common.utils.isNaN,
        function(l, r) {
          return l === r;
        });
    }
  }

  function checkRangeFilter(filterData, value, valueConverter, filterConverter, emptyValueCheck, equalFunc) {
    val = valueConverter(value);
    if (emptyValueCheck(val)) {
      return true;
    }
    if (typeof filterData.lte !== 'undefined' && !emptyValueCheck(filterConverter(filterData.lte)) && val > filterConverter(filterData.lte)) {
      return false;
    }
    if (typeof filterData.gte !== 'undefined' && !emptyValueCheck(filterConverter(filterData.gte)) && val < filterConverter(filterData.gte)) {
      return false;
    }
    if (typeof filterData.eq !== 'undefined' && !emptyValueCheck(filterConverter(filterData.eq)) && !equalFunc(val, filterConverter(filterData.eq))) {
      return false;
    }
    return true;
  }

  function convertSorter(left, right, converter) {
    var leftConverted = converter(left);
    var rightConverted = converter(right);
    if (leftConverted < rightConverted) {
      return 1;
    }
    if (leftConverted > rightConverted) {
      return -1;
    }
    return 0;
  }

  var publicData = {
    create: function(tableID, columns, data) {
      var table = $('#' + tableID);
      var tableCols = [];
      var tableFilters = [];
      for (var i = 0; i < columns.length; ++i) {
        var c = {};
        if (!FashionLime.Common.utils.isUndefined(columns[i].formatter)) {
          c.formatter = columns[i].formatter;
        } else {
          c.field =columns[i].id;
          c.title = columns[i].name;
          c.sortable = !FashionLime.Common.utils.isUndefined(columns[i].sortable) ? columns[i].sortable : true;

          if (!FashionLime.Common.utils.isUndefined(columns[i].dataType)) {
            if (columns[i].dataType === "date") {
              c.sorter = function(l, r) {
                return convertSorter(l, r, FashionLime.Common.utils.parseDate);
              };
            } else if (columns[i].dataType === "float") {
              c.sorter = function(l, r) {
                return convertSorter(l, r, FashionLime.Common.utils.parseFloat);
              };
            }
          }

          // By default all undefined filterable columns have filters
          if (columns[i].filterable || FashionLime.Common.utils.isUndefined(columns[i].filterable)) {
            var f = {
              field: columns[i].id,
              label: columns[i].name,
              type: !FashionLime.Common.utils.isUndefined(columns[i].filterType) ? columns[i].filterType : 'search'
            };
            tableFilters.push(f);
          }
        }
      
        tableCols.push(c);
      }

      var createTableParams = {
        locale:'bg-BG',
        showColumns: true,
        showExport: true,
        pagination: true,
        pageSize: 15,
        pageList: [15, 25, 50, 100, 'ВСИЧКИ'],
        columns: tableCols,
        data: data
      };

      var filterBarID = tableID + '_filter_bar';
      if (tableFilters.length > 0) {
        $(table).parent().prepend(FashionLime.Common.utils.format("<div id='{0}' class='bootstrap-table-filter-bar'></div>", filterBarID));
        createTableParams.toolbar = '#' + filterBarID;
      }

      $(table).bootstrapTable(createTableParams);

      if (tableFilters.length > 0) {
        var filterBar = $('#' + filterBarID);
        $(filterBar).bootstrapTableFilter({
          connectTo: '#' + tableID,
          locale: 'bg-BG',
          filters: tableFilters,
          onSubmit: function() {
            var data = $(filterBar).bootstrapTableFilter('getData');
            $(table).bootstrapTable('filterBy', data);
          }
        });
      }
    }
  };

  return publicData;
}());
