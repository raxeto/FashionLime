(function() {
  'use strict';

  FashionLime.Merchant.ProductPicturesImport.New = function(products) {
    this.products = products;
    this.productsSource = FashionLime.Shared.typeahead.createLocalSource("name", "id", products);
  };

  FashionLime.Merchant.ProductPicturesImport.New.prototype = {
    init: function(uploadUrl, footerTemplate, maxFileCount) {
      initFileInput(uploadUrl, footerTemplate, maxFileCount);
      $('#import-file-input').on('fileloaded', this.fileLoaded.bind(this));
      $('#import-file-input').on('fileunlock', this.fileUnlocked.bind(this));
    },

    fileLoaded: function(event, file, previewId, index, reader) {
      var productInput = '#product_name_' + index.toString();
      var productId = '#product_id_' + index.toString();
      FashionLime.Shared.typeahead.setup(productInput,
        this.productsSource,
        "name",
        "id",
        productId,
        2
      );
      var textInput = $(productInput)[0];
      var productChanged = function(event, suggestion) {
        if (!FashionLime.Common.utils.isString(suggestion)) {
          FashionLime.Common.net.sendGetRequest('/merchant/products/import_pictures/product_info',
            { product_id: suggestion.id, preview_id: previewId }, 
            onProductInfoResponse
          );
        }
      };
      FashionLime.Shared.typeahead.change(productInput, productChanged);
    },

    // Fired when all files are uploaded
    fileUnlocked: function(event, filestack, extraData) {
      var mainContainer = $('#import-file-input').parents('.file-input');
      mainContainer.removeClass('has-error');
      mainContainer.find('.file-preview-frame').each(function() {
        if ($(this).hasClass('file-preview-error')) {
          $(this).addClass('has-error');
        } else {
          $(this).find('.upload-success-message').show();
        }
      });
    }
  };

  function onProductInfoResponse(response) {
    if (!response) {
      return;
    }
    var filePreview = '#' + response.preview_id;
    if (response.not_found) {
      $(filePreview).find('.product-error').show();
      $('.determine-products-error').show();
      return;
    }
    var availableColors = response.colors;
    var colorSelect = $(filePreview).find('.color-id');
    var selectedColor = colorSelect.val() ? parseInt(colorSelect.val()) : 0;

    // Remove all but empty
    $(colorSelect).find('option').each(function() {
      var value = $(this).val();
      if (value) {
        $(this).remove();
      }
    });

    for (var i = 0; i < availableColors.length; ++i) {
      $(colorSelect).append($("<option></option>").
        attr("value", availableColors[i].id).
        text(availableColors[i].name)
      );
      if (availableColors[i].id === selectedColor) {
        $(colorSelect).val(selectedColor);
      }
    }

    if (response.color_required) {
      colorSelect.addClass('required-field');
      FashionLime.Validation.requiredField.setupControl(colorSelect);
      if (!$(colorSelect).val()) {
        colorSelect.parent().addClass('has-error');
      }
    } else {
      colorSelect.removeClass('required-field');
      colorSelect.parent().removeClass('has-error');
      FashionLime.Validation.requiredField.cleanupControl(colorSelect);
    }
  }

  function uploadPictureExtraData(previewId, index) {
    if (FashionLime.Common.utils.isUndefined(previewId)) {
      return {};
    }

    var preview = $('#' + previewId);
    var out = {};

    out["product_id"] = $(preview).find('.product-id').val();
    out["color_id"] = $(preview).find('.color-id').val();
    if ($(preview).find('.outfit-compatible:checked').length > 0) {
      out["outfit_compatible"] = 1;
    }
    out["order_index"] = $(preview).find('.order-index').val();
    return out;
  }

  function initFileInput(uploadUrl, footerTemplate, maxFileCount) {
    $("#import-file-input").fileinput({
      showUpload: true,
      maxFileCount: maxFileCount,
      language: 'bg',
      browseClass: "btn btn-default",
      layoutTemplates: { footer: footerTemplate },
      allowedFileTypes: ['image'],
      showCancel: false,
      showClose: false,
      overwriteInitial: false,
      previewThumbTags: {
          '_TAG_NUM_' : function() {
            return $('.picture-container').length;
          }
      },
      uploadExtraData: uploadPictureExtraData,
      uploadUrl: uploadUrl
    });
  }

}());
