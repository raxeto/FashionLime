FashionLime.Shared.newRecord = (function() {
  'use strict';

  var BUTTON_SELECTOR = '.btn-new-record';
  var PANEL_SELECTOR = '.new-record-wrapper';
  var SAVE_WARNING_CLASS = 'new-record-save-warning'
  var ANIMATION_DURATION = 400; // in miliseconds


  function onNewRecordButtonClicked() {
    $(PANEL_SELECTOR).show(ANIMATION_DURATION, null);
    $(BUTTON_SELECTOR).hide();
  }

  var publicData = {
    setup: function() {
      $(PANEL_SELECTOR).hide();
      $(BUTTON_SELECTOR).click(onNewRecordButtonClicked);
    },

    hidePanel: function() {
      $(PANEL_SELECTOR).hide();
      $(BUTTON_SELECTOR).show();
    },

    addInsertWarning: function() {
      var warningContainer = $('.' + SAVE_WARNING_CLASS);
      if (warningContainer.length === 0) {
        warningContainer = $("<div class='" + SAVE_WARNING_CLASS + "'></div>").insertBefore(PANEL_SELECTOR);
      }
      warningContainer.html(FashionLime.Common.notifications.renderWarning("Натиснете бутона 'Запази', за да запаметите новодобавените записи."));
    }
  };

  return publicData;
}());
