FashionLime.Rating.utils = (function() {
  'use strict';

  function getCurrentUserRating(container) {
    var userRatingControl = $(container).find('.user_rating');
    return parseInt(userRatingControl.text());
  }

  function onUpdateFailed(container, userRating, response) {
    if (response && response.status === FashionLime.Common.net.HTTP_CODES.FORBIDDEN) {
      // The user is not allowed to rate this product, so he should be a guest.
      // Prompt him to sign in / sign up.
      FashionLime.Common.utils.showLoginModal('За да оценявате продукти и визии трябва да влезете в системата.');
    }

    // Revert the last action.
    setRatings(container, 'invalidate', userRating);
  }

  function changeRating(button, id, modelType, command) {
    var container = getRatingContainer(button);
    var userRating = getCurrentUserRating(container);

    if ((command === 'increase' && userRating > 0) ||
        (command === 'decrease' && userRating < 0)) {
      command = 'invalidate';
    }

    setRatings(container, command, userRating);
    userRating = getCurrentUserRating(container);

    FashionLime.Common.webApi.changeRating(command, id, modelType).fail(
        onUpdateFailed.bind(this, container, userRating));
  }

  function setRatings(container, command, prevUserRating) {
    var newUserRating = 0;

    $(container).find('.btn-increase').removeClass('selected');
    $(container).find('.btn-decrease').removeClass('selected');

     switch(command) {
      case 'increase':
        newUserRating = 1;
        $(container).find('.btn-increase').addClass('selected');
        break;
      case 'decrease':
        newUserRating = -1;
        $(container).find('.btn-decrease').addClass('selected');
        break;
      case 'invalidate':
        newUserRating = 0;
        break;
    }

    var ratingControl = $(container).find('.rating')
    var rating = parseInt(ratingControl.text())
    ratingControl.text(rating - prevUserRating + newUserRating)
    $(container).find('.user_rating').text(newUserRating);
  }

  function getRatingContainer(button) {
    return $(button).closest('.rating_container')
  }

  var publicData = {
    increase: function(button, id, modelType) {
      changeRating(button, id, modelType, "increase");
    },
    decrease: function(button, id, modelType) {
      changeRating(button, id, modelType, "decrease");
    }
  };

  return publicData;
}());
