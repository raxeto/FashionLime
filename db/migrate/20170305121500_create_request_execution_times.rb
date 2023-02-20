class CreateRequestExecutionTimes < ActiveRecord::Migration
  def change
    create_table :request_execution_times do |t|
      t.string     :measure_type
      t.float      :request_time
      t.datetime   :scanned_at
      t.timestamps null: false
    end
  end
end
