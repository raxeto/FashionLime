class AddIndexesToRequestExecutionTimes < ActiveRecord::Migration
  def change
    add_index :request_execution_times, :measure_type
    add_index :request_execution_times, :created_at
  end
end
