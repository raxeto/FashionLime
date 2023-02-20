class AddUrlPathToProductAndOutfit < ActiveRecord::Migration
  def change
    change_table(:products) do |t|
      t.string     :url_path, null: false, limit: 1050, after: :rating
    end
    change_table(:outfits) do |t|
      t.string     :url_path, null: false, limit: 1050, after: :rating
    end
  end
end
