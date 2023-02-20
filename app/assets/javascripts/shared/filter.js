FashionLime.Shared.filter = (function() {
  
  var filterHolder = '#filtersExpander';

  function onCollapseFilters() {
    $(filterHolder).find('.btn-xs-expand-collapse')[0].click();
  }

  function onClearFilters() {
    $(filterHolder).find('.filter')
      .not(':button, :submit, :reset, :hidden, select')
      .val('');

    $(filterHolder).find('.filter option').removeAttr('selected')

    FashionLime.Shared.comboMultiselect.resetAll('filter');
  }

  var publicData = {
    setup: function() {
      $('.close-filters').click(onCollapseFilters);
      $('.clear-filters').click(onClearFilters);
    }
  };

  return publicData;
}());
