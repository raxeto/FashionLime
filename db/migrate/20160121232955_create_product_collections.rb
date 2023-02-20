class CreateProductCollections < ActiveRecord::Migration
  def change
    create_table :product_collections do |t|
      t.references :merchant, null: false, index: true
      t.string     :name, limit: 512, null: false
      t.text       :description, null: true
      t.references :season, null: false
      t.integer    :year, null: false
      t.timestamps null: false
    end
  end
end
