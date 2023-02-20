module Modules
  class OutfitDecorationJsonBuilder

    include Singleton
    include Modules::ClientUrlLib
    include Modules::ClientLib
    include Modules::CurrencyLib
    include SeoFriendlyImageHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::NumberHelper

    public

      def outfit_decorations_partial_data(decorations)
        res = []
        decorations.each do |d|
          res.push(thumb_partial_data(d))
        end
       return res
      end

    private

      def thumb_partial_data(decoration)
        data = {
          :image_url => {
            :original => decoration.picture.url(:original),
            :thumb => decoration.picture.url(:thumb)
          },
          :image_alt => seo_image_description(:outfit_decoration, decoration),
        }
        data.to_json
      end

  end
end

















