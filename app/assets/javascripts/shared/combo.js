FashionLime.Shared.combo = (function() {
  'use strict';

  function setupSingleCombo(comboId, additionalOptions) {
    var select = $('#' + comboId);

    // For responsive design
    $(select).css("width", "100%");

    var options = {
      theme: "bootstrap",
      language: "bg",
      minimumResultsForSearch: Infinity // hides the searchbox
    };
    
    if (!FashionLime.Common.utils.isUndefined(additionalOptions)) {
      for (var attrname in additionalOptions) { 
        options[attrname] = additionalOptions[attrname]; }
    }

    if ($(select).hasClass('combo-font-families')) {
      options["templateResult"] = formatFontFamily;
    } else if ($(select).hasClass('combo-colors')) {
      options["templateResult"] = formatColor;
    }
      
    return $(select).select2(options);
  }

  function formatFontFamily(state) {
    if (!checkState(state)) {
      return state.text; 
    }
    var ret = FashionLime.Common.utils.format("<span style='font-family: {0}; font-size: 12px;'>{1}</span>", $(state.element).attr("data-font-family"), state.text);
    return $(ret);
  }

  function formatColor(state) {
    if (!checkState(state)) {
      return state.text; 
    }
    var ret = FashionLime.Common.utils.format("<div><div class='combo-colors-option-box' style='background-color: {0};'>&nbsp;</div> {1}</div>", $(state.element).attr("data-color"), state.text);
    return $(ret);
  }
  
  function checkState(state) {
    if (!state.id) { 
      return false; 
    }
    return true;
  }
  
  var publicData = {
    setupSingle: function(comboId, additionalOptions) {
      return setupSingleCombo(comboId, additionalOptions);
    },

    setVal: function(combo, value) {
      combo.val(value).trigger("change");
    }
  };

  return publicData;
}());
