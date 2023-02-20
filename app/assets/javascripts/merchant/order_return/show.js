(function() {
  'use strict';

  FashionLime.Merchant.OrderReturn.Show = function() {
    this.selectedExchangeArticle = null;
  };

  FashionLime.Merchant.OrderReturn.Show.prototype = {

    init: function() {
      $('.btn-add-exchange-article').click(this.onAddExchangeArticleClicked.bind(this));
      $('.btn-save-exchange').click(this.onSaveExchangeClicked.bind(this))
      return this; 
    },

    setExchangeArticle: function(suggestion) {
      if (FashionLime.Common.utils.isString(suggestion)) {
        this.selectedExchangeArticle = null;
      } else {
        this.selectedExchangeArticle = suggestion;
      }
    },

    onAddExchangeArticleClicked: function() {
      if (FashionLime.Common.utils.isNull(this.selectedExchangeArticle)) {
        alert("Започнете да пишете името на артикула и го изберете от списъка с предложения, за да го добавите за замяна.");
        return;
      }
      var artId = this.selectedExchangeArticle.id;
      var artName = this.selectedExchangeArticle.full_name;
      var qty = 1;
      var priceWithDisc = this.selectedExchangeArticle.price_with_discount;
     
      this.addExchangeArticle(artId, artName, qty, priceWithDisc);
    },

    onSaveExchangeClicked: function() {
      var table = $('#newArticlesTable');
      if (FashionLime.Common.utils.getTableRowsCount(table) == 0) {
        alert("Няма артикули избрани за замяна. Използвайте бутона '+', за да добавите артикули.");
        return;
      }
      var newArticles = [];
      $(table).find('tr').each(function() {
        if ($(this).hasClass('article-row')) {
          newArticles.push({
            'article_id': $(this).find('.article-id-col').text(),
            'qty': $(this).find('.qty-input').val()
          });
        }
      });

      var form = $('#exchangeArticlesForm');
      form.find('#new_articles').val(JSON.stringify(newArticles));
      form.submit();
    },

    addExchangeArticle: function(artId, artName, qty, priceWithDisc) {
      var table = $('#newArticlesTable');
      if (FashionLime.Common.utils.getTableRowsCount(table) == 0) {
        table.append("<tr><th>ID артикул</th><th>Артикул</th><th>Цена с отстъпка</th><th>Количество</th></tr>");
      }
      var newRow = FashionLime.Common.utils.format("<tr class='article-row'><td class='article-id-col'>{0}</td><td>{1}</td><td>{2}</td><td><input type='number' min='0' value='{3}' class='form-control qty-input'></input></td></tr>",
          artId, artName, priceWithDisc, qty);
        $('#newArticlesTable').append(newRow);
    }
  };

}());



