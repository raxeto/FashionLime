class CreateArticleQuantities < ActiveRecord::Migration
  def change
    create_table :article_quantities do |t|
      t.references :article, null: false, index: true
      t.string     :part, null: true, limit: 128
      t.string     :note, null: true, limit: 2048
      t.decimal    :qty,  :precision => 8, :scale => 3, null: false, default: 0.0
      t.decimal    :qty_sold,  :precision => 8, :scale => 3, null: false, default: 0.0
      t.integer    :active, null: false, default: 1
      t.timestamps null: false
    end
  end
end
