(function() {
  'use strict';

  var DARKEN_BRIGHTNESS = -40;
  var BRIGHTEN_BRIGHTNESS = 35;
  var PRODUCT_PICTURE_RATIO = 0.75;
  var DECORATION_RATIO = 1.0;

  function increaseNewlyAdded() {
    $('#_newly_added_records').val(getNewlyAddedRecords() + 1);
  }

  function getNewlyAddedRecords() {
    return parseInt($('#_newly_added_records').val());
  }

  function getExistingRecords() {
    return parseInt($('#_existing_records').val());
  }

  function isFabricElement(element) {
    return element instanceof fabric.Object;
  }

  function isImageElement(element) {
    return element instanceof fabric.Image;
  }

  function isImageProductPicture(element) {
    if (element instanceof fabric.Image) {
      var url = element._originalElement.src;
      var ppFolder = "product_pictures/"
      return url.indexOf(ppFolder) >= 0;
    } else {
      return false;
    }
  }

  function isImageDecoration(element) {
    if (element instanceof fabric.Image) {
      return !isImageProductPicture(element);
    } else {
      return false;
    }
  }

  function isTextElement(element) {
    return element instanceof fabric.Text;
  }

  function hideImagePanel() {
    $('#images_panel').hide();
  }

  function clearTextPanel() {
    $('#element_text_input').val('');
  }

  FashionLime.Outfit.Form = function(productCollection, maxOccasionCount, canvasMaxImgWidth, unsuccessfulSave, comboTextFonts, colorSwatches) {
    this.productCollection = productCollection;
    this.canvas = null;
    this.isCanvasChanged = false;
    this.unsuccessfulSave = unsuccessfulSave;
    this.outfitSubmited = false;
    this.textElementMode = { insert: false, edit: false };
    this.textEditActivationInProgress = false;
    this.maxOccasionCount = maxOccasionCount;
    this.canvasMaxImgWidth = canvasMaxImgWidth;
    this.comboTextFonts = comboTextFonts;
    this.colorSwatches = colorSwatches;
    this.sliders = {};
    this.slidersState = {};
    this.initialized = false;
  };

  FashionLime.Outfit.Form.prototype = {
    init: function() {
      this.onItemsAdded = this.setupAddProduct.bind(this);
      this.onWindowBeforeUnloadEvent = this.onWindowBeforeUnload.bind(this, false);
      this.onPageBeforeChangeEvent = this.onWindowBeforeUnload.bind(this, true)
      this.setupCanvas();
      this.setupCanvasFunctions();
      this.setupFormSubmit();
      this.setupAddProduct();
      this.setupColorPickers();
      this.bindToEvents();
      this.loadCanvasContent();
      this.loadImageFilterValue();
      this.initialized = true;
      return this;
    },

    initFromCache: function() {
      if (!this.initialized) {
        this.init();
      } else {
        this.bindToEvents();
      }
    },

    setupAddProduct: function() {
      this.setupNewAddProductButtons();
      this.setupProductActionsHover();
    },

    setupColorPickers: function() {
      $('#element_text_color').minicolors({
        theme: 'bootstrap',
        control: 'saturation',
        swatches: this.colorSwatches
      });

      $('#element_text_color').minicolors('value', '#000000');

      $('#element_decoration_color').minicolors({
        theme: 'bootstrap',
        control: 'saturation',
        swatches: this.colorSwatches
      });
    },

    setupCanvas: function() {
      this.canvas = new fabric.Canvas('outfit_canvas');
      this.canvas.selection = false; // Disable group selection, not elements selection
      this.canvas.on('object:selected', this.onCanvasSelectedElementChanged.bind(this));
      this.canvas.on('object:added', this.onCanvasContentChanged.bind(this));
      this.canvas.on('object:removed', this.onCanvasContentChanged.bind(this));
      this.canvas.on('object:modified', this.onCanvasContentChanged.bind(this));
      this.canvas.on('selection:cleared', this.hideOptionPanels);
      FashionLime.Shared.responsiveCanvas.setup(this.canvas, "canvas_container");
      this.allowTouchScrolling();
      // The canvas is initialized, remove preloading of the fonts
      $('.fonts-preloading-panel').remove();
    },

    setupCanvasFunctions: function() {
      var that = this;
      $('#remove_element_button').click(this.onRemoveElementClicked.bind(this));
      $('#clear_all_elements_button').click(this.onClearAllElementsClicked.bind(this));
      $('#add_text_element_button').click(this.onAddTextElementClicked.bind(this));
      $('.add_decoration_button').click(function() {
        that.onAddDecorationsClicked(this);
      });
      $('.add_outfit_decoration').click(function() {
        that.onAddDecorationClicked(this);
      });
      $('#element_text_bold').click(this.onTextElementBoldClicked.bind(this));
      $('#element_text_italic').click(this.onTextElementItalicClicked.bind(this));
      $('#add_text_ok_button').click(this.onAddTextOK.bind(this));
      $('#add_text_cancel_button').click(this.hideFeaturePanels);
      $('.text_element_setting').change(this.onTextSettingsChanged.bind(this));
      $('#add_images_settings_button').click(this.toggleImagePanelVisibility.bind(this));
      $('#image_filters_list').change(this.onImageFilterChanged.bind(this));
      $('#add_decoration_color_ok_button').click(this.onAddDecorationColorOk.bind(this))
      $('#add_decoration_color_cancel_button').click(this.hideOptionPanels);
    },

    setupFormSubmit: function() {
      var that = this;
      FashionLime.Common.utils.onFormSubmit("#outfit_form", function() {
        return that.submitForm();
      });
      $('#btn-save').click(this.onSaveClicked.bind(this));
    },

    loadCanvasContent: function() {
      var serializedJSON = $('#outfit_serialized_json').val();
      var that = this;
      FashionLime.Outfit.utils.loadCanvasContent(this.canvas, serializedJSON, function() {
        that.isCanvasChanged = that.unsuccessfulSave;
      });
    },

    loadImageFilterValue: function() {
      var imageFilter = $('#outfit_image_filter').val();
      $('#image_filters_list').val(imageFilter);
    },

    bindToEvents: function() {
      FashionLime.Common.eventManager.bind('newItemsAdded', this.onItemsAdded);
      $(window).on('beforeunload', this.onWindowBeforeUnloadEvent);
      $(document).on('page:before-change', this.onPageBeforeChangeEvent);
    },

    cleanup: function() {
      if (this.initialized) {
        FashionLime.Common.eventManager.unbind('newItemsAdded', this.onItemsAdded);
        $(window).off('beforeunload', this.onWindowBeforeUnloadEvent);
        $(document).off('page:before-change', this.onPageBeforeChangeEvent);
      }
    },

    onSaveClicked: function() {
      if (this.getProductPicturesCount() == 0) {
        alert("Визията няма добавени продукти. Добавете с помощта на дадения списък с продукти.");
        return;
      }
      $('#outfit-attrubutes-modal').modal();
    },

    onAddProductClicked: function(button, productId) {
      var container = $(button).closest('.outfit-product');
      // Hide actions when the product is already added
      var actions = $(container).find('.product-action');
      actions.addClass('hidden-actions-class');
      this.showPicturesModal(productId);
    },

    onRemoveElementClicked: function() {
      var activeObj = this.getActiveElement();
      if (activeObj) {
        if (isImageProductPicture(activeObj)) {
          this.removeProductPicture(activeObj);
        }
        activeObj.remove();
      }
      else {
        if (this.getElementsCount() > 0) {
          alert("Моля изберете елемент.");
        }
      }
    },

    onClearAllElementsClicked: function() {
      if (this.getElementsCount() === 0) {
        return;
      }
      var result = confirm("Сигурни ли сте, че искате да изтриете всички елементи от визията и да започнете отначало?");
      if (result === true) {
        var elements = this.canvas.getObjects();
        var elementsToRemove = [];
        for (var i = 0; i < elements.length; ++i) {
          if (isImageProductPicture(elements[i])) {
            this.removeProductPicture(elements[i]);
          }
          elementsToRemove.push(elements[i]);
        }
        for (var i = 0; i < elementsToRemove.length; ++i) {
          this.canvas.remove(elementsToRemove[i]);
        }
      }
    },

    toggleImagePanelVisibility: function() {
      // var panel = $('#images_panel');
      // if (panel.is(":visible")) {
      //   hideImagePanel();
      // }
      // else {
      //   if ($('#text_panel').is(":visible")) {
      //     this.toggleTextPanelVisibility();
      //   }
      //   panel.show();
      // }
    },


    onAddTextElementClicked: function() {
      if (isTextElement(this.getActiveElement())) {
        this.canvas.discardActiveObject();
        return;
      }
      if (!$('#text_panel').is(":visible")) {
        clearTextPanel();
        this.enterTextMode("insert");
        this.setTextButtonsVisibility();
      }
      this.tooglePanelVisibility($('#text_panel'));
    },

    onAddDecorationsClicked: function(button) {
      var category = $(button).attr('data-decoration-category');
      this.initDecorationSlider(category);
      this.tooglePanelVisibility($('.decorations-category-' + category));
    },

    onAddDecorationClicked: function(link) {
      var container = $(link).closest('.outfit-decoration');
      var imageUrl = container.find('.decoration_image_url').val();
      this.addImageToCanvas(imageUrl, DECORATION_RATIO);
      this.hideFeaturePanels();
    },

    onAddDecorationColorOk: function() {
      var decoration = this.getActiveElement();
      var color = $('#element_decoration_color').val();
      if (!FashionLime.Common.utils.isUndefinedOrEmpty(color)) {
        var filter = new fabric.Image.filters.Tint({
          color: color,
          opacity: 0.67
        });
        if (decoration.filters.length > 0) {
          decoration.filters.pop();
        }
        decoration.filters.push(filter);
        decoration.applyFilters(this.canvas.renderAll.bind(this.canvas));
      }
      this.hideOptionPanels();
    },

    tooglePanelVisibility: function(panel) {
      if ($(panel).is(":visible")) {
        $(panel).hide();
      }
      else {
        this.hideFeaturePanels();
        this.hideOptionPanels();
        $(panel).show();
      }
    },

    hideFeaturePanels: function() {
      $('.features-panel').hide();
    },

    hideOptionPanels: function() {
      $('.options-panel').hide();
    },

    showOptionsPanel: function(panel) {
      this.hideFeaturePanels();
      this.hideOptionPanels();
      $(panel).show();
    },

    initDecorationSlider: function(category) {
      var sliderId = category + "-outfit-decorations";
      if (this.slidersState[sliderId] === "initialized") {
        return;
      } 
      if (this.slidersState[sliderId] === "cached") {
        this.slidersState[sliderId] = "initialized";
        slider = this.sliders[sliderId].initFromCache();
        return;
      }

      this.slidersState[sliderId] = "initialized";
      var slider = new FashionLime.Shared.Slider(
        sliderId, 
        5,
        [{ breakpoint: 560, items_count: 4 }, { breakpoint: 440, items_count: 3 }]
      );
      slider.init();

      this.sliders[sliderId] = slider;

      var that = this;

      FashionLime.Common.utils.onLoadFromCache(function() {
        if (that.isSliderVisible(sliderId)) {
          slider.initFromCache();
          that.slidersState[sliderId] = "initialized";
        }
      }, '#canvas_functions_toolbar');

      FashionLime.Common.utils.onPageUnload(function() {
        slider.cleanup();
        that.slidersState[sliderId] = "cached";
      }, '#canvas_functions_toolbar');
    },

    isSliderVisible: function(sliderId) {
      return $('#' + sliderId).closest('.features-panel').is(":visible");
    },

    activateEditTextPanel: function(activeObj) {
      this.enterTextMode("edit");
      this.setTextButtonsVisibility();
      this.textEditActivationInProgress = true;
      $('#element_text_input').val(activeObj.text);
      $('#element_text_color').minicolors('value', activeObj.getFill());
      FashionLime.Shared.combo.setVal(this.comboTextFonts, activeObj.fontFamily);
      var btnBold = $('#element_text_bold');
      this.removeButtonActive(btnBold);
      if (activeObj.fontWeight === 'bold') {
        this.changeButtonStatus(btnBold);
      }
      var btnItalic = $('#element_text_italic');
      this.removeButtonActive(btnItalic);
      if (activeObj.fontStyle === 'italic') {
        this.changeButtonStatus(btnItalic);
      }
      this.textEditActivationInProgress = false;
    },

    setTextElementSettings: function(element) {
      if (FashionLime.Common.utils.isNull(element)) {
        return;
      }
      element.setText($('#element_text_input').val());
      var selectedFontFamily = $('#element_text_font_family option:checked')
      if (selectedFontFamily.val()) {
        element.setFontFamily(selectedFontFamily.val());
      }
      var selectedColor = $('#element_text_color').val();
      if (selectedColor) {
        element.setColor(selectedColor);
        element.setStroke(selectedColor);
      }
      if (this.isButtonActive($('#element_text_bold'))) {
        element.setFontWeight('bold');
      } else {
        element.setFontWeight('normal');
      }
      if (this.isButtonActive($('#element_text_italic'))) {
        element.setFontStyle('italic');
      } else {
        element.setFontStyle('normal');
      }
    },

    onTextElementBoldClicked: function() {
      this.changeButtonStatus($('#element_text_bold'));
      this.onTextSettingsChanged();
    },

    onTextElementItalicClicked: function() {
      this.changeButtonStatus($('#element_text_italic'));
      this.onTextSettingsChanged();
    },

    changeButtonStatus: function(button) {
      if ($(button).hasClass('active')) {
        $(button).removeClass('active');
      } else {
        $(button).addClass('active');
      }
    },

    isButtonActive: function(button) {
      return $(button).hasClass('active');
    },

    removeButtonActive: function(button) {
      $(button).removeClass('active');
    },

    onAddTextOK: function() {
      var textInput = $('#element_text_input')
      if (!textInput.val()) {
        alert('Моля, въведете текст.');
        return;
      }
      this.addTextToCanvas(textInput.val());
    },

    onCanvasSelectedElementChanged: function(e) {
      var activeObject = e.target;
      var panel = null;
      if (isTextElement(activeObject)) {
        panel = $('#text_panel');
        this.activateEditTextPanel(activeObject);
      } else if (isImageDecoration(activeObject)) {
        panel = $('#decorations-color');
        $('#element_decoration_color').minicolors('value', "");
      }

      this.showOptionsPanel(panel);
    },

    onCanvasContentChanged: function(e) {
      this.isCanvasChanged = true;
    },

    onTextSettingsChanged: function() {
      if (this.textElementMode.edit && !this.textEditActivationInProgress) {
        this.setTextElementSettings(this.editedTextElement);
        this.canvas.renderAll();
      }
    },

    onImageFilterChanged: function() {
      var selectedFilter = $('#image_filters_list option:checked').val();
      $('#outfit_image_filter').val(selectedFilter);
      this.applyFilter(selectedFilter);
    },

    applyFilter: function(filterToApply, onFilterApplied) {
      var filter = null;
      switch (filterToApply) {
        case "Darken":
          filter = new fabric.Image.filters.Brightness({
            brightness: DARKEN_BRIGHTNESS
          });
          break;
        case "Brighten":
          filter = new fabric.Image.filters.Brightness({
            brightness: BRIGHTEN_BRIGHTNESS
          });
          break;
        case "Sharpen":
          filter = new fabric.Image.filters.Convolute({
            matrix: [ 0, -1,  0,
                     -1,  5, -1,
                      0, -1,  0 ]
          });
          break;
        case "Grayscale":
          filter = new fabric.Image.filters.Grayscale();
          break;
        case "Noise":
          filter = new fabric.Image.filters.Noise({
            noise: 60
          });
          break;
        case "Default":
          filter = new fabric.Image.filters.Brightness({
            brightness: 1
          });
          break;
        default:
          filter = new fabric.Image.filters.CustomFilter({
            filterType: filterToApply
          });
      }

      var elements = this.canvas.getObjects();
      var that = this;
      for (var i = 0; i < elements.length; ++i) {
        if (isImageElement(elements[i])){
          elements[i].filters.pop();
          if (filter !== null) {
            elements[i].filters.push(filter);
          }
          elements[i].applyFilters(function() {
            that.canvas.renderAll(that.canvas);
            if (!FashionLime.Common.utils.isUndefined(onFilterApplied)) {
              onFilterApplied();
            }
          });
        }
      }
    },

    submitForm: function() {
      if (this.getProductPicturesCount() == 0) {
        return false;
      }

      var form = $('#outfit_form');
      var error = false;
      var requiredFields = ["outfit_name", "outfit_outfit_category_id"];
      for (var i = 0; i < requiredFields.length; ++i) {
        var field = $('#' + requiredFields[i]);
        if (FashionLime.Common.utils.isNullOrEmpty(field.val())) {
          error = true;
          field.parent().addClass("has-error");
        }
      }

      var occasionsControl = $('#outfit_occasion_ids');
      var selectedOccasions = occasionsControl.find(':selected').size();
      var occasionError = false;
      if (selectedOccasions == 0) {
        $('.blank-occasions-error').show();
        occasionError = true;
      } else {
        $('.blank-occasions-error').hide();
      }
      if (selectedOccasions > this.maxOccasionCount) {
        $('.max-occasions-error').show();
        occasionError = true;
      } else {
        $('.max-occasions-error').hide();
      }
      if (occasionError) {
        occasionsControl.parent().addClass("has-error");
        error = true;
      } else {
        occasionsControl.parent().removeClass("has-error");
      }

      if (error) {
        return false;
      }

      this.setSerializedCanvas();
      this.outfitSubmited = true;

      return true;
    },

    // var calledFromDefaultFilter = false;

    setSerializedCanvas: function() {
      // if (calledFromDefaultFilter) {
      //   calledFromDefaultFilter = false;
      //   // For each case :)
      //   $('#outfit_serialized_json').val(JSON.stringify(this.canvas));
      //   $('#serialized_svg').val(this.canvas.toSVG());
      //   return true;
      // }

      // // Only if there is no filter selected
      // // Workaround because RMagick do not work on the server
      // if (!$('#outfit_image_filter option:checked').val()) {
      //   applyFilter("Default", function() {
      //     $('#outfit_serialized_json').val(JSON.stringify(canvas));
      //     $('#serialized_svg').val(canvas.toSVG());
      //     calledFromDefaultFilter = true;
      //     $('#outfit_form').submit();
      //   });
      //   return false;
      // }


      $('#outfit_serialized_json').val(JSON.stringify(this.canvas));

      var canvasWidth = this.canvas.getWidth();

      // Scale canvas for small screens in order to have image with better quality on the server
      if (canvasWidth < this.canvasMaxImgWidth) {
        $('#canvas_container .canvas-container').hide();
        $('#outfit_saving_prompt').show();
        this.scaleCanvas(this.canvasMaxImgWidth / canvasWidth);
      }
      $('#serialized_svg').val(this.canvas.toSVG());
    },

    addImageToCanvas: function(imageUrl, pictureRatio) {
      var that = this;
      fabric.Image.fromURL(imageUrl, function(oImg) {
        oImg.height = that.canvas.height / 2.0;
        oImg.width = oImg.height * pictureRatio;
        that.canvas.add(oImg);
        that.canvas.setActiveObject(oImg);
      });
    },

    addTextToCanvas: function(text) {
      var textInstance = new fabric.Text('', {
        fontSize: 72,
        strokeWidth: 0
      });
      this.setTextElementSettings(textInstance);
      this.canvas.add(textInstance);
      this.canvas.setActiveObject(textInstance);
    },

    addProductPicture: function(productPictureID, product){
      this.productCollection.addOne(product);

      var container = $('#outfit_product_pictures_container');
      var found = false;
      $(container).find('.product_picture_id').each(function () {
        if (productPictureID === parseInt($(this).val())) {
          found = true;
          var instances = $(this).siblings('.instances_count')
          instances.val(parseInt(instances.val()) + 1);
        }
      });
      if (!found) {
        var hiddenTemplateName = "template_row_index";
        var templateHidden = $("#" + hiddenTemplateName);
        var template = $(templateHidden).parent();
        var templateIndex = parseInt(templateHidden.val());
        var index = getExistingRecords() + getNewlyAddedRecords() + 1;
        increaseNewlyAdded();

        var newContainer = $(template).clone(true);
        $(newContainer).find('.product_picture_id').val(productPictureID);
        $(newContainer).find('.product_id').val(product.product.id);
        $(newContainer).find('.color_id').val(product.color !== null ? product.color.id : 0);
        $(newContainer).find('.instances_count').val(1);

        var newHiddenTemplate;
        var templatePrefix = "outfit_outfit_product_pictures_attributes_"+templateIndex+"_";
        $(newContainer).find("*").each(function() {
          var child = $(this);
          var id = child.attr('id');
          if (id === hiddenTemplateName){
            newHiddenTemplate = child;
          }
          if (id && id.startsWith(templatePrefix)){
            child.attr('id', id.replace("_"+templateIndex+"_", "_"+index+"_"));
            child.attr('name', child.attr('name').replace("["+templateIndex+"]", "["+index+"]"));
          }
        });
         // Remove template marker
        $(newHiddenTemplate).remove();
        // Add new container
        $(container).prepend(newContainer);
      }
    },

    removeProductPicture: function(activeObj) {
      var url = activeObj._originalElement.src;
      var ppFolder = "product_pictures/"
      var ppIndexStart = url.indexOf(ppFolder);
      if (ppIndexStart === -1) {
        return;
      }
      ppIndexStart += ppFolder.length;
      var ppIndexEnd = url.indexOf('/', ppIndexStart);
      var productPictureID = parseInt(url.substring(ppIndexStart, ppIndexEnd));
      var productID, colorID;
      $('.instances_count').each(function () {
        var ppID = parseInt($(this).siblings('.product_picture_id').val());
        if (ppID === productPictureID){
          productID = parseInt($(this).siblings('.product_id').val());
          colorID = parseInt($(this).siblings('.color_id').val());
          $(this).val($(this).val() - 1);
        }
      });
      this.productCollection.delete(productID, colorID);
    },

    showPicturesModal: function(productId) {
      var modalWindow = $('#product-pictures-modal');
      this.initPicturesModal(modalWindow, productId);
      $(modalWindow).modal();
    },

    initPicturesModal: function(modalWindow, productId) {
      var outfitPictures = $(modalWindow).find('.outfit-pictures');
      var allPictures = $(modalWindow).find('.all-pictures');

      $(outfitPictures).html('');
      $(allPictures).html('');
      $(modalWindow).find('.pictures-title').hide();

      var that = this;
      var onResponse = function(response) {
        if (!response || response.status === false) {
          return;
        }
        for (var i = 0; i < response.length; ++i) {
          var container = (response[i].outfit_compatible == 1) ? outfitPictures : allPictures;
          $(container).append(that.getProductPicturePartial(response[i]))
          // Show the title when at least one picture from the section is found
          $(container).siblings('.pictures-title').show();
        }
        $(modalWindow).find('.add_product_picture').click(function() {
          that.onAddProductPictureClicked(this);
        });
      };
      FashionLime.Common.net.sendGetRequest('/outfits/pictures_for_product/' + productId, {}, onResponse);
    },

    onAddProductPictureClicked: function(button) {
      $('#product-pictures-modal').modal("hide");
      var container = $(button).closest('.outfit-product-picture');
      var productPictureID = parseInt($(container).find('.product_picture_id').val());
      var imageUrl = $(container).find('.product_image_url').val();
      this.addImageToCanvas(imageUrl, PRODUCT_PICTURE_RATIO);
      this.addProductPicture(productPictureID, this.getProductJson(container));
    },

    getProductPicturePartial: function(pp) {
      return FashionLime.Common.utils.format(
        "<div class='col-xs-6 col-ms-3 col-sm-3 col-md-2'>{0}</div>",
        FashionLime.Outfit.productPicture.get(pp)
      );
    },

    getProductJson: function(container) {
      return {
          product: {
            id: parseInt($(container).find('.product_product_id').val()),
            name: $(container).find('.product_product_name').val()
          },
          color: {
            id: parseInt($(container).find('.product_color_id').val()),
            name: $(container).find('.product_color_name').val()
          },
          min_price: FashionLime.Common.utils.parseFloat($(container).find('.product_min_price').val()),
          max_price: FashionLime.Common.utils.parseFloat($(container).find('.product_max_price').val())
        };
    },

    getElementsCount: function() {
     return this.canvas.getObjects().length;
    },

    getProductPicturesCount: function() {
      var elements = this.canvas.getObjects();
      var imagesCount = 0;
      for (var i = 0; i < elements.length; ++i) {
        if (isImageProductPicture(elements[i])) {
          ++imagesCount;
        }
      }
      return imagesCount;
    },

    getActiveElement: function() {
     return this.canvas.getActiveObject();
    },

    enterTextMode: function(mode) {
      if (mode == "insert") {
        this.textElementMode.insert = true;
        this.textElementMode.edit = false;
      }
      else {
        this.textElementMode.insert = false;
        this.textElementMode.edit = true;
        this.editedTextElement = this.getActiveElement();
      }
    },

    showTextPanel: function() {
      this.setTextButtonsVisibility();
      var textPanel = $('#text_panel'); 
      if (textPanel.is(":visible")) {
        return;
      }
      this.tooglePanelVisibility(textPanel);
    },

    setTextButtonsVisibility: function() {
      if (this.textElementMode.insert) {
        $('#add_text_ok_button').show();
        $('#add_text_cancel_button').show();
      }
      else {
        $('#add_text_ok_button').hide();
        $('#add_text_cancel_button').hide();
      }
    },

    onWindowBeforeUnload: function(displayConfirm) {
      if (!this.outfitSubmited && this.isOutfitChanged()) {
        var message = "Не сте записали промените по визията."
        if (displayConfirm) {
          return confirm(message + " Потвърждавате ли напускане на страницата?");
        }
        else {
          return message;
        }
      }
    },

    allowTouchScrolling: function() {
      var canvasObj = this.canvas;
      canvasObj.allowTouchScrolling = true;

      var disableScroll = function() {
        canvasObj.allowTouchScrolling = false;
      };
      var enableScroll = function() {
        canvasObj.allowTouchScrolling = true;
      };
      canvasObj.on('object:selected', disableScroll);
      canvasObj.on('selection:cleared', enableScroll);
    },

    setupNewAddProductButtons: function() {
      var that = this;
      $('#item-list .add_picture_button.not_yet_added').each(function () {
        var productId = parseInt($(this).siblings('.product_id').val());
        $(this).click(that.onAddProductClicked.bind(that, this, productId));
        $(this).removeClass('not_yet_added');
      });
    }, 

    setupProductActionsHover: function() {
      var removeHiddenFunc = function(outfitProduct) {
        $(outfitProduct).find('.product-action').removeClass('hidden-actions-class');
      };

      $('#item-list .outfit-product').each(function() {
        $(this).hover(function() {
            removeHiddenFunc(this);  // Hover in
          }, function() {
            removeHiddenFunc(this);  // Hover out
          }
        );
      });
    },

    // http://stackoverflow.com/questions/28301286/scale-fabric-js-canvas-objects
    scaleCanvas: function(factor) {
      this.canvas.setHeight(this.canvas.getHeight() * factor);
      this.canvas.setWidth(this.canvas.getWidth() * factor);
      if (this.canvas.backgroundImage) {
          // Need to scale background images as well
          var bi = this.canvas.backgroundImage;
          bi.width = bi.width * factor; bi.height = bi.height * factor;
      }
      var objects = this.canvas.getObjects();
      for (var i in objects) {
          var scaleX = objects[i].scaleX;
          var scaleY = objects[i].scaleY;
          var left = objects[i].left;
          var top = objects[i].top;

          var tempScaleX = scaleX * factor;
          var tempScaleY = scaleY * factor;
          var tempLeft = left * factor;
          var tempTop = top * factor;

          objects[i].scaleX = tempScaleX;
          objects[i].scaleY = tempScaleY;
          objects[i].left = tempLeft;
          objects[i].top = tempTop;

          objects[i].setCoords();
      }
      this.canvas.renderAll();
      this.canvas.calcOffset();
    },

    isOutfitChanged: function() {
      return this.isCanvasChanged;
    }

  };

}());
