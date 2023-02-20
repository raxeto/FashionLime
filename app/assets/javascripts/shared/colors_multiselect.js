FashionLime.Shared.colorsMultiselect = (function() {
  'use strict';
  var holder = null;

  function colorSelectionChanged() {
    var selectOption = $(this).find('.color-select-option');
    if (selectOption.hasClass('selected')) {
      selectOption.removeClass('selected');
    } else {
      selectOption.addClass('selected');
    }

    // Trigger the on change event on the holder element.
    $(holder).change();
  }

  function clear() {
    $(holder).find('.color-select-option.selected').removeClass('selected');
  }

  function getSelected() {
    var colors = [];
    $(holder).find('.color-select-option.selected').each(function() {
      colors.push(parseInt($(this).attr("data-color-id")));
    });
    return colors;
  }

  var publicData = {
    preselectIds: function(colorIds) {
      $(holder).find('.color-select-option').each(function() {
        if (colorIds.indexOf($(this).attr('data-color-id')) !== -1) {
          $(this).addClass('selected');
        }
      });
    },

    setup: function(holderSelector) {
      holder = holderSelector;
      var links = $(holderSelector + ' .color-select-link');
      $(links).click(colorSelectionChanged);

      $(holder).data('clearSelectedColors', clear);
      $(holder).data('getSelectedColors', getSelected);
    }
  };

  return publicData;
}());
