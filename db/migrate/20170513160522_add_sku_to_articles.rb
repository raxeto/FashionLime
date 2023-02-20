class AddSkuToArticles < ActiveRecord::Migration
  def change
    change_table(:articles) do |t|
      t.string :sku
    end

    add_index :articles, :sku
  end
end
