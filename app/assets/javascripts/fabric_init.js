(function() {
  'use strict';

  var SELECTION_COLOR = "#444452";
  var SELECTION_CORNER_COLOR = "rgba(68, 68, 82, 0.7)";
  var SELECTION_COLOR_BACKGROUND = "rgba(68, 68, 82, 0.3)";

  var setDefaults = function() {
    // http://fabricjs.com/customization
    fabric.Canvas.prototype.selectionColor = SELECTION_COLOR_BACKGROUND;
    fabric.Canvas.prototype.selectionBorderColor = SELECTION_COLOR;

    fabric.Object.prototype.set({
      borderColor: SELECTION_COLOR,
      cornerColor: SELECTION_CORNER_COLOR,
      transparentCorners: false
    });
  };

  setDefaults();
  
}());

