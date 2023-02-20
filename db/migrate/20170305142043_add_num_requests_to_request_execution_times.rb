class AddNumRequestsToRequestExecutionTimes < ActiveRecord::Migration
  def change
    change_table(:request_execution_times) do |t|
      t.integer :num_requests
    end
  end
end
