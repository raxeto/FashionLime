# https://github.com/collectiveidea/delayed_job/tree/v4.1.2#gory-details

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 2
Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))
