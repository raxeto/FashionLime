module Modules
  module PictureLib

      def image_width(picture, style)
        PictureLib.image_width_from_geometry(picture.styles[style].geometry)
      end

      def image_height(picture, style)
        PictureLib.image_height_from_geometry(geometry = picture.styles[style].geometry)
      end

      def self.image_width_from_geometry(geometry)
        geometry[0..(geometry.index('x') - 1)]
      end

      def self.image_height_from_geometry(geometry)
        last_sym = geometry[geometry.length - 1]
        height_end =  (last_sym >= '0' && last_sym <= '9') ? geometry.length - 1 : geometry.length - 2
        geometry[(geometry.index('x') + 1)..height_end]
      end

  end
end
