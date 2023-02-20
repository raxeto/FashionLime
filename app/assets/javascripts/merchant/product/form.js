FashionLime.Merchant.Product.form = (function() {
  'use strict';

  function productCategoryChanged() {
    filterSizes();
  }

  function filterSizes() {
    FashionLime.Common.net.sendGetRequest('/merchant/products/size_categories_for_product_category', {
      product_category_id: $('.product-category-id').val()
    }, onGetSizesResponse);
  }

  function onGetSizesResponse(response) {
    if (!response || !response.status) {
      return;
    }
    var select = $('.sizes');
    var size_ids = $(select).val();
    var categories = JSON.parse(response.categories);
    var selectHtml = "";
    for (var i = 0; i < categories.length; ++i) {
      var sizes = categories[i].sizes;
      selectHtml += FashionLime.Common.utils.format("<optgroup label='{0}'>", categories[i].name);
      for (var j = 0; j < sizes.length; ++j) {
        selectHtml += FashionLime.Common.utils.format("<option value='{0}'>{1}</option>", sizes[j].id, sizes[j].name);
      }
      selectHtml += "</optgroup>";
    }
    select.html(selectHtml);
    select.val(size_ids);
    $(select).multiselect('rebuild');
  }

  var publicData = {
    setup: function() {
      $('.product-category-id').change(productCategoryChanged);
      filterSizes();
    }
  };

  return publicData;
}());
