class AddLockingToArticleQuantity < ActiveRecord::Migration
  def change
     change_table(:article_quantities) do |t|
      t.integer :lock_version, default: 0, after: :active
    end
  end
end
