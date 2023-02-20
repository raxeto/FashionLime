require 'test_helper'

class ProductPictureTest < ActiveSupport::TestCase
  test "product picture order_index" do
    pic = ProductPicture.create({
        product_id: 1
      })
    assert pic.persisted?
    assert_equal 1, pic.order_index

    second_pic = ProductPicture.create({
        product_id: 1
      })
    assert second_pic.persisted?
    assert_equal 2, second_pic.order_index

    third_pic = ProductPicture.create({
        product_id: 1,
        order_index: -1
      })
    assert !third_pic.persisted?

    fourth_pic = ProductPicture.create({
        product_id: 1,
        order_index: 40
      })
    assert fourth_pic.persisted?
    assert_equal 40, fourth_pic.order_index

    fifth_pic = ProductPicture.create({
        product_id: 1
      })
    assert fifth_pic.persisted?
    assert_equal 41, fifth_pic.order_index

    sixth_pic = ProductPicture.create({
        product_id: 1,
        order_index: 15
      })
    assert sixth_pic.persisted?
    assert_equal 15, sixth_pic.order_index

    seventh_pic = ProductPicture.create({
        product_id: 1
      })
    assert seventh_pic.persisted?
    assert_equal 42, seventh_pic.order_index
  end
end
