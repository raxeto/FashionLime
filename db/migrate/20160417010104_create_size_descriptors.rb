class CreateSizeDescriptors < ActiveRecord::Migration
  def change
    create_table :size_descriptors do |t|
      t.string     :name, null: false,  limit: 1024
      t.integer    :order_index, null: false, default: 1
      t.timestamps null: false
    end
  end
end
