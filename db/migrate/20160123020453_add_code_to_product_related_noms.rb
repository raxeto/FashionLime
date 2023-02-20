class AddCodeToProductRelatedNoms < ActiveRecord::Migration
  def change
    change_table(:trade_marks) do |t|
      t.string :key, null: true, limit: 128
    end

    change_table(:colors) do |t|
      t.string :key, null: true, limit: 128
    end

    change_table(:sizes) do |t|
      t.string :key, null: true, limit: 128
    end

    add_index :trade_marks, [:key], :unique => true
    add_index :colors, [:key], :unique => true
    add_index :sizes, [:key], :unique => true
    add_index :occasions, [:key], :unique => true

  end
end
