namespace :clean do
  desc "Cleans old request stats"
  task :old_request_stats => "setup:fashionlime" do
    sql = 'DELETE FROM request_execution_times WHERE updated_at < DATE_SUB(NOW(), INTERVAL 10 DAY);'
    ActiveRecord::Base.connection.execute(sql)
  end
end
