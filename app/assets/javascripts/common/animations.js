FashionLime.Common.animations = (function() {
  'use strict';

  var publicData = {

    // Fix for IE 9 where CSS animations are not supported
    // front.js animations function set the opacity of all elements with data-animate attribute to 0
    browserCompatible: function() {
      if (!Modernizr.cssanimations) {
        $('[data-animate]').css('opacity', 1);
      } 
    },
  }

  return publicData;
}());






