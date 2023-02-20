FashionLime.Outfit.partial = (function() {
  'use strict';

  var publicData = {

    get: function(outfit, picStyle, showCreator, showName, ratingSize, showUserBtnDelete) {
      picStyle = !FashionLime.Common.utils.isUndefined(picStyle)? picStyle : "thumb";
      ratingSize = !FashionLime.Common.utils.isUndefined(ratingSize)? ratingSize : "sm";
      showUserBtnDelete = !FashionLime.Common.utils.isUndefined(showUserBtnDelete)? showUserBtnDelete : false;
      
      return HandlebarsTemplates['outfits/outfit']({
        outfit: outfit,
        locals: {
          image_url: outfit.image_url[picStyle],
          show_creator: !FashionLime.Common.utils.isUndefined(showCreator)? showCreator : true,
          show_name: !FashionLime.Common.utils.isUndefined(showName)? showName : true,
          show_btn_edit: outfit.profile_id == outfit.user_info.profile_id,
          show_btn_delete: (showUserBtnDelete && outfit.profile_id == outfit.user_info.profile_id) || outfit.user_info.is_admin,
          rating_params: FashionLime.Rating.partial.formatParams(outfit.id, 'Outfit', outfit.rating, outfit.user_rating, ratingSize)
        }
      });
    }
  };

  return publicData;
}());
