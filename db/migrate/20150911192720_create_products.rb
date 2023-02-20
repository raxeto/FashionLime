class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :merchant, null: false, index: true
      t.references :trade_mark, null: true, index: true
      t.references :user, null: false, index: false
      t.string     :name, null: false, limit: 1024
      t.text       :description
      t.integer    :status, null: false, default: 1
      t.float      :rating, null: false, default: 0.0
      t.timestamps null: false
    end

  end
end
