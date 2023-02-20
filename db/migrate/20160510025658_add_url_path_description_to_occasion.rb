class AddUrlPathDescriptionToOccasion < ActiveRecord::Migration
  def change
    change_table(:occasions) do |t|
      t.text       :description, null: true, after: :name
      t.string     :url_path, null: false, limit: 255, after: :key
    end
    add_index :occasions, [:url_path], :unique => true
  end
end
