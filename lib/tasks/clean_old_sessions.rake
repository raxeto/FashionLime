namespace :clean do
  desc "Cleans older sessions"
  task :old_sessions => "setup:fashionlime" do
    sql = 'DELETE FROM sessions WHERE updated_at < DATE_SUB(NOW(), INTERVAL 20 DAY);'
    ActiveRecord::Base.connection.execute(sql)
  end
end
