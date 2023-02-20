class AddPictureWatermarkUrlToProducts < ActiveRecord::Migration
  def change
    change_table(:products) do |t|
      t.string    :picture_watermark_url, limit: 1024, null: true
    end
  end
end
