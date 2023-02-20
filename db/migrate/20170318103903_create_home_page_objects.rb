class CreateHomePageObjects < ActiveRecord::Migration
  def change
    create_table :home_page_objects do |t|
      t.references :home_page_variant, null: false, index: true
      t.references :object, polymorphic: true, null: false
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
  end
end
