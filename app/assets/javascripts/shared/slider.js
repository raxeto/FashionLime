(function() {
  'use strict';

  FashionLime.Shared.Slider = function(sliderId, visibleItems, breakpoints) {
    this.sliderId = sliderId;
    this.visibleItems = visibleItems;
    this.breakpoints = breakpoints;
  };

  FashionLime.Shared.Slider.prototype = {
    init: function() {
      var that = this;
      
      $("#" + this.sliderId + " .arrow-left").click(onLeftArrowClicked.bind(this));
      $("#" + this.sliderId + " .arrow-right").click(onRightArrowClicked.bind(this));

      this.createLightSlider();

      return this;
    },

    initFromCache: function() {
      this.createLightSlider();
    },

    cleanup: function() {
      this.sliderObject.destroy();
      this.sliderObject = null;
    },

    createLightSlider: function() {
      var responsiveBreakpoints = [];
      for (var i = 0; i < this.breakpoints.length; i++) { 
        responsiveBreakpoints.push({
          breakpoint: this.breakpoints[i].breakpoint,
          settings: {
              item: this.breakpoints[i].items_count
            }
        });
      }

      this.sliderObject = $("#" + this.sliderId + " .slider-control").lightSlider({
        item: this.visibleItems,
        slideMargin: 30,
        pager: true,
        controls: false,
        prevHtml: '<i class="fa fa-arrow-circle-o-left" aria-hidden="true"></i>',
        nextHtml: '<i class="fa fa-arrow-circle-o-left" aria-hidden="true"></i>',
        responsive: responsiveBreakpoints
      }); 
    }
  };

  // Private methods.

  function onLeftArrowClicked() {
    this.sliderObject.goToPrevSlide();
  }

  function onRightArrowClicked() {
    this.sliderObject.goToNextSlide();
  }

}());

