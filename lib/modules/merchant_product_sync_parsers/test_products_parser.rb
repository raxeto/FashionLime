module Modules
  module MerchantProductSyncParsers
    class TestProductsParser < BaseProductsParser
      public
        def process(merchant, file_str)
          return [
            {
              :name => "Рокля с екзотичен принт",
              :description => "Opisanie na test 1",
              :trade_mark_id => 1,
              :product_category_id => 6,
              :occasion_ids => [2,3],
              :product_pictures => [
                {
                  :source_url => "https://fashionlime.bg/system/product_pictures/2535/pictures/original/roklq-s-ekzotichen-print.jpg",
                  :outfit_compatible => false,
                  :color_id => 5
                },
                {
                  :source_url => "https://fashionlime.bg/system/product_pictures/2536/pictures/original/roklq-s-ekzotichen-print.jpg",
                  :outfit_compatible => false,
                  :color_id => 5
                },
              ],
              :articles => [
                {
                  :size_id => 5,
                  :color_id => 4,
                  :price => 50,
                  :price_with_discount => 42,
                  :sku => "RJR568",
                  :qty => 1
                },
                {
                  :size_id => 4,
                  :color_id => 7,
                  :price => 50,
                  :price_with_discount => 2.4,
                  :sku => "RJR568",
                  :qty => 7
                }
              ]
            }
          ]

        end
    end
  end
end

