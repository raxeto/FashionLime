class ChangeMerchantProductsSyncTasksCronDailyUpdateTime < ActiveRecord::Migration
  def change
    change_column :merchant_products_sync_tasks, :cron_daily_update_time, :string
  end
end
