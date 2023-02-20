class AddUrlPathToProductCollection < ActiveRecord::Migration
  def change
    change_table(:product_collections) do |t|
      t.string     :url_path, null: false, limit: 255, after: :year
    end
    ProductCollection.all.each { |c| c.update_attributes(:url_path => c.name.parameterize)}
  end
end
