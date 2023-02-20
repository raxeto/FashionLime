FashionLime.Shared.fabricCustomFilter = (function() {
  'use strict';

  fabric.Image.filters.CustomFilter = fabric.util.createClass({
    type: 'CustomFilter',

    initialize: function(options) {
      options = options || { };
      this.filterType = options.filterType;
    },

    applyTo: function(canvasEl) {
      var context = canvasEl.getContext('2d'),
          imageData = context.getImageData(0, 0, canvasEl.width, canvasEl.height),
          data = imageData.data;

      $.filterMe.apply(this.filterType, data);

      context.putImageData(imageData, 0, 0);
    },

    toObject: function() {
      return { 
        type: this.type ,
        filterType: this.filterType
      };
    }
  });

  fabric.Image.filters.CustomFilter.fromObject = function(object) {
    return new fabric.Image.filters.CustomFilter(object);
  };
}());
