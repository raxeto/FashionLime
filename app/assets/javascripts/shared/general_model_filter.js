(function() {
  'use strict';

  FashionLime.Shared.GeneralModelFilter = function(modelNameStr, loadMoreUrlStr, updateUrl, bootstrapItemColClass, modelPartial) {
    this.itemCount = 0;
    this.filterHolder = '.item-filters-holder';
    this.syncUrl = updateUrl;
    this.bootstrapItemColClass = bootstrapItemColClass;
    this.modelPartial = modelPartial;

    this.itemHolder = null;
    this.stopLoad = false;
    this.modelName = modelNameStr;
    this.initialBatchSize = FashionLime.Constants[this.modelName.toUpperCase() + '_INDEX_INITIAL_BATCH_SIZE'];
    this.batchSize = FashionLime.Constants[this.modelName.toUpperCase() + '_INDEX_BATCH_SIZE'];
    this.loadMoreUrl = loadMoreUrlStr;

    this.footer = '#items-footer';
    this.filterOrSortChangedCallback = this.onFilterOrSortChanged.bind(this);
  };

  FashionLime.Shared.GeneralModelFilter.prototype = {

    init: function() {
      $('.clear-filters').click(this.onClearFilters.bind(this));
      $(this.filterHolder).find('.fashionlime-filter, .colors-multiselect').not('.multiselect-combo').
          change(this.filterOrSortChangedCallback);

      this.scrollHandler = this.onScroll.bind(this);
      return this; // for chaining
    },

    onFilterOrSortChanged: function() {
      var params = this.buildParams();
      if (this.syncUrl) {
        FashionLime.Common.utils.jsonToUrlParams(params);
      }
      FashionLime.Common.webApi.loadNextItemBatch(this.modelName, this.loadMoreUrl,
          params, 0, self.initialBatchSize, this.onAllItemsLoaded.bind(this));
    },

    buildParams: function() {
      var params = {};
      $(this.filterHolder).find('.fashionlime-filter').each(function() {
        var val = $(this).val();
        if (val) {
          params[$(this).attr('id')] = val;
        }
      });

      var colorPicker = $(this.filterHolder).find('.colors-multiselect');
      if (colorPicker.size() > 0) {
        params['colors'] = $(colorPicker).data('getSelectedColors')();
      }

      return params;
    },

    cleanFooter: function () {
      $(this.footer).hide();
      this.stopAutoLoad();
    },

    onItemsLoaded: function(response) {
      this.addItems(response);
    },

    onAllItemsLoaded: function(response) {
      this.setItems(this.itemHolder, response, this.initialBatchSize);
    },

    onScroll: function() {
      if (FashionLime.Common.utils.checkIsVisible(this.footer) && !this.stopLoad) {
        var params = this.buildParams();
        FashionLime.Common.webApi.loadNextItemBatch(this.modelName, this.loadMoreUrl,
            params, this.itemCount, this.batchSize, this.onItemsLoaded.bind(this));
        // Don't send any requests while still waiting for the response.
        this.stopAutoLoad();
      }
    },

    startAutoLoad: function() {
      $(window).scroll(this.scrollHandler);
      this.stopLoad = false;
    },

    stopAutoLoad: function() {
      $(window).unbind('scroll', this.scrollHandler);
      this.stopLoad = true;
    },

    onClearFilters: function() {
      // Clear the color select.
      var colorPicker = $(this.filterHolder).find('.colors-multiselect');
      if (colorPicker.size() > 0) {
        $(colorPicker).data('clearSelectedColors')();
      }

      this.onFilterOrSortChanged();
    },

    addItems: function(items) {
      if (items.length) {
        var html = '';
        for (var i = 0; i < items.length; ++i) {
          html += ('<div class="' + this.bootstrapItemColClass + '">' + FashionLime.Common.utils.execModelPartial(this.modelPartial, items[i]) + '</div>');
        }
        $(this.itemHolder).append(html);
        this.itemCount += this.batchSize;
        // Because of merchant profile tooltip
        $('[data-toggle="tooltip"]').tooltip();

        this.startAutoLoad();

        FashionLime.Common.eventManager.fire('newItemsAdded');
      } else {
        this.cleanFooter();
      }
    },

    setItems: function(holder, items, itemCount) {
      $(holder).empty();
      this.itemHolder = holder;
      this.addItems(items);
      this.itemCount = itemCount;
      if (FashionLime.Common.utils.checkIsVisible(this.footer)) {
        this.onScroll();
      }
    },

    cleanup: function() {
      this.stopAutoLoad();
    },

    loadedFromCache: function() {
      this.startAutoLoad();
    }
  };

}());
