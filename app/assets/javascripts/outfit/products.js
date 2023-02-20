(function() {
  'use strict';

  function renderProducts(products) {
    var tableBody = getTableBody();
    if (products.length > 0) {
      getTableHeader().show();
      getTableFooter().show();
    } else {
      getTableHeader().hide();
      getTableFooter().hide();
    }
    tableBody.html(''); // Clear content
    for (var i = 0; i < products.length; ++i) {
      var product = products[i];
      var html = FashionLime.Common.utils.format("<tr><td> {0} </td><td>{1}</td><td class='right-aligned'> {2} </td><td class='right-aligned'>{3}</td><td class='right-aligned'>{4}</td><tr>",
        product.product.name,
        product.color !== null ? product.color.name : "",
        product.qty,
        FashionLime.Common.utils.toCurrencyRange(product.min_price, product.max_price),
        FashionLime.Common.utils.toCurrencyRange(product.min_price * product.qty, product.max_price * product.qty)
        );
      $(tableBody).append(html);
    }
  }

  function calcTotal(products) {
    var min_total = 0.0;
    var max_total = 0.0;
    for (var i = 0; i < products.length; ++i) {
        min_total += products[i].min_price * products[i].qty;
        max_total += products[i].max_price * products[i].qty;
    }
    min_total = FashionLime.Common.utils.roundFloat(min_total, 2);
    max_total = FashionLime.Common.utils.roundFloat(max_total, 2);
    // TODO Constants
    var html = FashionLime.Common.utils.toCurrencyRange(min_total, max_total);
    $('#outfit_total').html(html);
  }

  function indexOfProduct(products, productID, colorID) {
    for (var i = 0; i < products.length; ++i) {
      if (products[i].product.id === productID && (products[i].color !== null ? products[i].color.id : 0) === colorID) {
        return i;
      }
    }
    return -1;
  }

  function getTable() {
    return $('#outfit_products_table')
  }

  function getTableBody() {
    return $('#outfit_products_table tbody')
  }

  function getTableHeader() {
    return $('#outfit_products_table thead')
  }

  function getTableFooter() {
    return $('#outfit_products_table tfoot')
  }

  function initTable() {
    var table = getTable();
    $(table).append("<thead class='centered-header'><tr><th>Продукт</th><th>Цвят</th><th>Количество</th><th>Цена</th><th>Общо</th></th></thead>");
    $(table).append('<tbody></tbody>')
  }

  FashionLime.Outfit.Products = function() {
    this.products = [];
    initTable();
  };

  FashionLime.Outfit.Products.prototype = {
    products: null,

    addMany: function(json_products) {
      for (var i = 0; i < json_products.length; ++i) {
        this.products.push(json_products[i]);
      }
      renderProducts(this.products);
      calcTotal(this.products);
    },

    addOne: function(product) {
      var ind = indexOfProduct(this.products, product.product.id, product.color !== null ? product.color.id : 0);
      if (ind < 0) {
        product.qty = 1;
        this.products.push(product);
      } else {
        ++this.products[ind].qty;
      }
      renderProducts(this.products);
      calcTotal(this.products);
    },

    delete: function(productID, colorID) {
      var ind = indexOfProduct(this.products, productID, colorID);
      if (ind > -1) {
        var product = this.products[ind];
        --product.qty;
        if (product.qty <= 0){
          this.products.splice(ind, 1);
        }
        renderProducts(this.products);
        calcTotal(this.products);
      }
    }
  };
}());
