class AddSerializedSvgToOutfit < ActiveRecord::Migration
  def change
    change_table(:outfits) do |t|
      t.binary :serialized_svg, null: true, limit: 32.megabytes, after: :serialized_json
    end
  end
end
