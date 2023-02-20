namespace :check do
  desc "Reads the nginx logs and scans for slow requests"
  task :nginx_logs => "setup:fashionlime" do
    t = Time.now
    scan_logs(t)
  end

  def parse_line(line)
    begin
      d = DateTime.strptime(line.match(/\[.*\]/).to_s[1..-2], "%d/%b/%Y:%H:%M:%S %Z")
      request_time = line.scan(/\([0-9\.]+\)/)[1].to_s[1..-2].to_f
      return d, request_time
    rescue
      Rails.logger.error("Failed parsing the line '#{line}'")
      return nil, nil
    end
  end

  def is_line_too_old(line_created_at, curr_time)
    return line_created_at.to_i / 60 < (curr_time.to_i / 60) - 1
  end

  def add_request_execution_times(scan_time, max_time, mean_time, median_time, num_requests)
    RequestExecutionTime.create(measure_type: 'max', request_time: max_time,
        scanned_at: scan_time, num_requests: num_requests)
    RequestExecutionTime.create(measure_type: 'avg', request_time: mean_time,
        scanned_at: scan_time, num_requests: num_requests)
    RequestExecutionTime.create(measure_type: 'med', request_time: median_time,
        scanned_at: scan_time, num_requests: num_requests)
  end

  def parse_line_url(line)
    return line.match(/"[^"]+"/).to_s[1..-2]
  end

  def scan_logs(curr_time)
    Rails.logger.info("Checking logs for #{curr_time}")
    log_file = "#{Dir.home}/web/shared/log/nginx.access.log"
    request_times = []
    slowest_rt = -1
    url = nil

    File.readlines(log_file).reverse_each do |l|
      line_time, rt = parse_line(l)
      if line_time.nil?
        next
      end
      if is_line_too_old(line_time, curr_time)
        break
      end

      request_times << rt
      if rt > slowest_rt
        slowest_rt = rt
        url = parse_line_url(l)
      end
    end

    if request_times.blank?
      Rails.logger.info("No requests were made this minute #{curr_time}")
      add_request_execution_times(curr_time, 0, 0, 0, 0)
      return
    end

    Rails.logger.info("#{request_times.size} requests parsed")

    max_time = request_times.max
    total_time = request_times.sum
    mean_time = total_time / request_times.size
    request_times.sort
    median_time = request_times[request_times.size / 2]
    add_request_execution_times(curr_time, max_time, mean_time, median_time, request_times.size)

    if slowest_rt > 1.0
      Rails.logger.info("Notifying the admins that a slow request to #{url} has been detected. Execution time #{slowest_rt} seconds")
      AdminMailer.new_slow_request_tracked(slowest_rt, url).deliver_now
    end

    # Adjust the laod time by the number of puma workers (cores)
    total_time /= 3.0
    if total_time > 30.0
      Rails.logger.info("Notifying the admins that the total time for processing requests this minute was #{total_time} seconds")
      AdminMailer.new_server_epoll_bellow_50(total_time).deliver_now
    end

    Rails.logger.info("Done. Slowest request time: #{slowest_rt} seconds")
  end
end
