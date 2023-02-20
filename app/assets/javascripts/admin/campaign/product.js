FashionLime.Admin.Campaign.product = (function() {
  'use strict';

  var publicData = {

    get: function(product) {
      var partial = FashionLime.Product.partial.get(product, "medium");
      return (
        '<button type="button" class="btn btn-sm btn-template-main btn-add" onclick="FashionLime.Admin.Campaign.addObjects.addClicked(this);">+ADD</button>'+
        '<button type="button" class="btn btn-sm btn-template-main btn-remove" onclick="FashionLime.Admin.Campaign.addObjects.removeClicked(this);">-Del</button>' +
        '<span class="campaign-object-id" style="display: none;">' + product.id + '</span>' +
        '<button type="button" class="btn btn-sm btn-template-main btn-left" onclick="FashionLime.Admin.Campaign.addObjects.moveLeft(this);"><i class="fa fa-arrow-left" aria-hidden="true"></i></button>'+
        '<button type="button" class="btn btn-sm btn-template-main btn-right" onclick="FashionLime.Admin.Campaign.addObjects.moveRight(this);"><i class="fa fa-arrow-right" aria-hidden="true"></i></button>'+
        partial
      );
    }
  };
  return publicData;
}());
