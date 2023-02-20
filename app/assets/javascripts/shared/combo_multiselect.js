FashionLime.Shared.comboMultiselect = (function() {
  'use strict';

  function setupAllMultiselects(className, additionalOptions) {
    $('.multiselect-combo.' + className).each(function() {
      var options = {
        nonSelectedText: '&nbsp;',
        enableHTML: true,
        maxHeight: 200,
        buttonWidth: '100%',
        allSelectedText: 'Всички опции',
        nSelectedText: 'избрани',
        selectedClass: 'multiselect-combo-selected',
        enableClickableOptGroups: true
      };
      
      if (!FashionLime.Common.utils.isUndefined(additionalOptions)) {
        for (var attrname in additionalOptions) { 
          options[attrname] = additionalOptions[attrname]; }
      }
      
      if ($(this).hasClass('multiselect-combo-searchable')) {
        options.enableFiltering = true;
        options.enableCaseInsensitiveFiltering = true;
        options.filterPlaceholder = 'Търси';
      }

      var that = this;
      if ($(this).hasClass('multiselect-combo-colors')) {
        options.enableHTML = true;
        options.optionLabel = function(element) {
          var colorId = $(element).val();
          var selectOption = $(that).find("option[value='" + colorId + "']");
          
          var colorBackground = selectOption.attr("data-background-image");
          var colorCode = selectOption.attr("data-color");
          
          var boxStyle = !FashionLime.Common.utils.isNullOrEmpty(colorBackground) ? 'background-image: url("' + colorBackground + '")' : 'background-color: ' + colorCode;
          var colorBox = "<div class='multiselect-combo-colors-option-box' style='"+boxStyle+"'></div>";
          
          return colorBox + $(element).html();
        };
      }
      $(this).multiselect(options);
    });
  }

  var publicData = {
    setupAll: function(className, additionalOptions) {
      setupAllMultiselects(className, additionalOptions);
    },

    resetAll: function(className) {
      $('.multiselect-combo.' + className).multiselect('refresh');
    }
  };

  return publicData;
}());
