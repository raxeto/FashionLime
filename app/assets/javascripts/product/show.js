(function() {
  'use strict';

  FashionLime.Product.Show = function(productId, pictures, hasDifferentPrices, hasColorSizeSelects) {
    if (hasColorSizeSelects){
      FashionLime.Product.utils.setupColorSelect($('.product_container')[0], productId, hasDifferentPrices);
      FashionLime.Product.utils.setupSizeSelect($('.product_container')[0], hasDifferentPrices);
      FashionLime.Product.utils.loadSizesForColor($('.product_container')[0], productId, hasDifferentPrices);
      getForm().find('.color_id').change(this.onSelectedColorChanged.bind(this));
      FashionLime.Common.utils.onFormSubmit(getForm(), this.onFormSubmit);
    }
   
    $('.sp-wrap').smoothproducts();
    this.pictures = pictures;
    this.selectPictureForColor();

    // Workaround for scroll bug
    // https://github.com/kthornbloom/Smoothproducts/issues/34
    $('.sp-thumbs a').click(function() {
      setTimeout(function() {
        if (!FashionLime.Common.utils.checkIsVisible($('.sp-large'))) {
          $("html, body").scrollTop($(".sp-wrap").offset().top);
        }
      }, 10);
    });
  };

  FashionLime.Product.Show.prototype = {
    getSelectedPicture: function() {
      var domPic = $('.sp-current');
      var url = domPic.attr('href');
      for (var i = 0; i < this.pictures.length; ++i) {
        if (this.pictures[i].url === url) {
          return this.pictures[i];
        }
      }

      return null;
    },

    selectPictureForColor: function() {
      if (this.pictures.length < 2) {
        return;
      }
      var selectedColor = getSelectedColor();
      var colorStr = null;
      if (selectedColor) {
        colorStr = selectedColor.text();
      }
      var selected = this.getSelectedPicture();
      if (selected && selected.color === colorStr) {
        // The picture is already for that color.
        return;
      }
      var picture = null;
      var colorlessPic = null;
      for (var i = 0; i < this.pictures.length; ++i) {
        if (this.pictures[i].color === colorStr) {
          picture = this.pictures[i];
          break;
        } else if (!this.pictures[i].color && !colorlessPic) {
          colorlessPic = this.pictures[i];
        }
      }

      // Default to the first picture for all colors.
      if (!picture && selected.color && colorlessPic) {
        picture = colorlessPic;
      }
      if (picture) {
        $('.sp-thumbs').find('a[href="' + picture.url + '"]').click();
      } else {
        // No suitable picture to show.
      }
    },

    onSelectedColorChanged: function() {
      this.selectPictureForColor();
    },

    onFormSubmit: function() {
      if ($('.color_id').val() && $('.size_id').val()) {
        return true;
      }
      alert('Цвят и размер трябва да бъдат избрани.');
      return false;
    }
  };

  function getSelectedColor() {
    return $(getForm()).find('.color_id option:checked');
  }

  function getForm() {
    return $('#product_form');
  }

}());
