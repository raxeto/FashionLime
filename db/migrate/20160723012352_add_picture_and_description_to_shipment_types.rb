class AddPictureAndDescriptionToShipmentTypes < ActiveRecord::Migration
  def change
    change_table(:shipment_types) do |t|
      t.text       :description, null: true, after: :name
      t.attachment :picture, after: :description
    end
  end
end
