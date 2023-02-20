class AddInProgressToMerchantProductsSyncTasks < ActiveRecord::Migration
  def change
    change_table(:merchant_products_sync_tasks) do |t|
      t.integer    :in_progress, after: :parser_class_name
    end
  end
end
