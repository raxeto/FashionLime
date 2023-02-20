class CreateMerchantProductsSyncTasks < ActiveRecord::Migration
  def change
    create_table :merchant_products_sync_tasks do |t|
      t.references  :merchant, index: true
      t.time        :cron_daily_update_time, null: false
      t.string      :scrape_url, null: false
      t.string      :parser_class_name, null: false

      t.timestamps null: false
    end
  end
end
