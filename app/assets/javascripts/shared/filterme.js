FashionLime.Shared.filterMe = (function() {
  'use strict';

  // Code is from the filterme plugin, but applied in our context

  $.filterMe.deSaturateData = function(saturation, data) {
    var length = data.length,
        average;

    // Apply the desaturation
    for ( var i = 0; i < length; i += 4 ) {
      average = ( data[ i ] + data[ i+1 ] + data[ i+2 ] ) / 3;
      data[ i ] += ( Math.round( average - data[ i ] * saturation ) );
      data[ i+1 ] += ( Math.round( average - data[ i+1 ] * saturation ) );
      data[ i+2 ] += ( Math.round( average - data[ i+2 ] * saturation ) );
    }
  },

  $.filterMe.addCurvesData = function(curves, data) {
    var i, length = data.length;

    // Apply the color R, G, B values to each individual pixel
    for ( i = 0; i < length; i += 4 ) {
      if (data[i] > 251 && data[i+1] > 251 && data[i+2] > 251) {
        continue; // Do not change white background
      }
      data[ i ] = curves.r[ data[ i ] ];
      data[ i+1 ] = curves.g[ data[ i+1 ] ];
      data[ i+2 ] = curves.b[ data[ i+2 ] ];
    }

    // Apply the overall RGB contrast changes to each pixel
    for ( i = 0; i < length; i += 4 ) {
      data[ i ] = curves.a[ data[ i ] ];
      data[ i+1 ] = curves.a[ data[ i+1 ] ];
      data[ i+2 ] = curves.a[ data[ i+2 ] ];
    }
  },

  $.filterMe.apply = function(filterType, data){
    var f = $.filterMe.filters[filterType];
    if (!f) {
      return;
    }
     
    // Apply desaturation
    if (f.desaturate)
      $.filterMe.deSaturateData(f.desaturate, data);

    // Apply curves effect
    if (f.curves)
      $.filterMe.addCurvesData(f.curves, data);

    // Apply vignette effect - not used for now
    // if (f.vignette)
    //   $.filterMe.addVignetteData(data);
  }

}());

