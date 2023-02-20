FashionLime.Rating.partial = (function() {
  'use strict';

  var publicData = {

    get: function(id, type, rating, userRating, ratingSize) {
      return Handlebars.partials['shared/_rating'](publicData.formatParams(id, type, rating, userRating, ratingSize));
    },

    formatParams: function(id, type, rating, userRating, ratingSize) {
      var btnGroupSize = !FashionLime.Common.utils.isUndefinedOrEmpty(ratingSize) ? ("btn-group-" + ratingSize) : "";
      return {
        id: id,
        type: type,
        rating: rating,
        user_rating: userRating,
        locals: {
          btn_group_size: btnGroupSize,
          dislike_button_class: (userRating == -1 ? 'selected' : ''),
          like_button_class: (userRating == 1 ? 'selected' : '')
        }
      };
    }
  };

  return publicData;
}());
