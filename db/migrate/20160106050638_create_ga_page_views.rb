class CreateGaPageViews < ActiveRecord::Migration
  def change
    create_table :ga_page_views do |t|
      t.references :related_model, polymorphic: true
      t.references :user, null: true, index: true
      t.datetime   :view_date, null: false

      t.string     :previous_page, limit: 4096, null: true
      t.string     :user_type, limit: 128, null: true
      t.string     :device_category, limit: 128, null: true
      t.string     :city, limit: 512, null: true

      t.integer    :page_views, null: true
      t.integer    :unique_page_views, null: true
      t.integer    :time_on_page, null: true
    end
    add_index :ga_page_views, [:related_model_id, :related_model_type]
  end
end
