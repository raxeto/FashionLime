FashionLime.Shared.responsiveCanvas = (function() {
  'use strict';

  function setCanvasDimensions(canvas, canvasContainerId) {
    var width = $('#' + canvasContainerId).width();
    canvas.setWidth(width);
    canvas.setHeight(width);
  }

  function onWindowResize(canvas, canvasContainerId) {
    setCanvasDimensions(canvas, canvasContainerId);
  }
  
  var publicData = {
    setup: function(canvas, canvasContainerId) {
      var windowResizeEvent = onWindowResize.bind(this, canvas, canvasContainerId);
      
      setCanvasDimensions(canvas, canvasContainerId);
      $(window).on('resize', windowResizeEvent);
      
      FashionLime.Common.utils.onLoadFromCache(function() {
        setCanvasDimensions(canvas, canvasContainerId);
        $(window).on('resize', windowResizeEvent);
      }, '#' + canvasContainerId);

      FashionLime.Common.utils.onPageUnload(function() {
        $(window).off('resize', windowResizeEvent);
      }, '#' + canvasContainerId);
    }
  };

  return publicData;
}());
