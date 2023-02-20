(function() {
  'use strict';

  window.FashionLime.Outfit.Show = function(outfitId, serializedJSON, popupShare) {
    this.outfitId = outfitId;
    this.serializedJSON = serializedJSON;
    this.popupShare = popupShare;
    this.askAttempts = 10;
    this.askFirstInterval = 5000;
    this.askInterval = 3000; // in milliseconds
    this.shouldStop = false;
    this.hasAnswer = false;
  };

  FashionLime.Outfit.Show.prototype = {

    init: function() {
      var canvasSelector = $("#outfit-canvas");
      if (canvasSelector.length === 0) {
        this.hasAnswer = true;
      } else {
        this.createCanvas();
        this.startAsking();  
      }
    },

    startAsking: function() {
      $('.social-share').hide();
      this.askAttempts = 10;
      this.shouldStop = false;
      this.hasAnswer = false;
      setTimeout(this.askIfPictureGenerated.bind(this), this.askFirstInterval);
    },

    askIfPictureGenerated: function() {
      var that = this;
      function onResponse(response) {
        if (that.shouldStop) {
          return;
        }
        if (response && response.status) {
          that.hasAnswer = true;
          that.shouldStop = true;
          $('.social-share').show();
          if (that.popupShare) {
            FashionLime.Common.socialUtils.openFbShareDialog();
          }
        } else {
          that.askAttempts--;
          if (that.askAttempts > 0) {
            setTimeout(that.askIfPictureGenerated.bind(that), that.askInterval);
          }
        }
      }
      FashionLime.Common.webApi.checkOutfitPictureGenerated(this.outfitId, onResponse);
    },

    createCanvas: function() {
      var canvas = new fabric.StaticCanvas("outfit-canvas");
      FashionLime.Outfit.utils.loadCanvasContent(canvas, this.serializedJSON);
      FashionLime.Shared.responsiveCanvas.setup(canvas, "outfit-canvas-container");
    },

    cleanup: function() {
      this.shouldStop = true;
    },

    loadedFromCache: function() {
      if (!this.hasAnswer) {
        this.startAsking();
      }
    }
  };

}());

