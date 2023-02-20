FashionLime.Product.partial = (function() {
  'use strict';

  var publicData = {

    get: function(product, picStyle, showOwner, showName, ratingSize, pictureWatermarkClass) {
      picStyle = !FashionLime.Common.utils.isUndefined(picStyle)? picStyle : "thumb";
      ratingSize = !FashionLime.Common.utils.isUndefined(ratingSize)? ratingSize : "sm";
      pictureWatermarkClass = !FashionLime.Common.utils.isUndefined(pictureWatermarkClass)? pictureWatermarkClass : "";
      return HandlebarsTemplates['products/product']({
        product: product,
        locals: {
          pic_style: picStyle,
          image_url: product.image_url[picStyle],
          show_owner: !FashionLime.Common.utils.isUndefined(showOwner)? showOwner : true,
          show_name: !FashionLime.Common.utils.isUndefined(showName)? showName : true,
          has_watermark: !FashionLime.Common.utils.isUndefinedOrEmpty(product.picture_watermark_url),
          picture_watermark_class: pictureWatermarkClass,
          has_discount: !FashionLime.Common.utils.isNullOrEmpty(product.discount),
          has_deleted_price: !FashionLime.Common.utils.isNullOrEmpty(product.deleted_price),
          multiple_colors: (product.colors.length > 1),
          rating_params: FashionLime.Rating.partial.formatParams(product.id, 'Product', product.rating, product.user_rating, ratingSize)
        }
      });
    }
  };

  return publicData;
}());
