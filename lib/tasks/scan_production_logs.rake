namespace :check do
  desc "Reads the production logs and scans for errors and requests with return HTTP status 500"
  task :production_logs => "setup:fashionlime" do
    t = Time.now
    scan_production_logs(t)
  end

  def parse_line_for_time(line)
    begin
      # 2017-04-07T06:37:06.350009 #11718
      # 07/Apr/2017:10:51:07 +0300
      d = DateTime.strptime(line[4..22], "%Y-%m-%dT%H:%M:%S")
      d = d.change(:offset => "+0300")
      return d
    rescue Exception => e
      Rails.logger.error("Failed parsing the line '#{line}' #{e}")
      return nil
    end
  end

  def has_status_500?(line)
    line.include?('Completed 500 Internal Server Error')
  end

  def has_error?(l)
    if /error|warning/i.match(l)
      if l.include?('Rendered errors/show') || l.include?('ErrorsController') || l.include?('RoutingError')
        Rails.logger.info("Skipping line #{l}")
      else
        return true
      end
    end
    return false
  end

  def is_production_line_too_old(line_created_at, curr_time)
    return line_created_at + 11.minutes < curr_time
  end

  def scan_production_logs(curr_time)
    Rails.logger.info("Checking logs for #{curr_time}")
    log_file = "#{Dir.home}/web/shared/log/production.log"
    errors = []
    checked = 0

    File.readlines(log_file).reverse_each do |l|
      line_time = parse_line_for_time(l)
      checked += 1
      if line_time.present? && is_production_line_too_old(line_time, curr_time)
        break
      end

      if has_status_500?(l)
        errors << "Got a request with code 500: #{l}"
      elsif has_error?(l)
        errors << "Line with error: #{l}"
      end
    end

    Rails.logger.info("Checked #{checked} requests")

    if errors.blank?
      Rails.logger.info("No bad requests were made this minute #{curr_time}")
      return
    end

    Rails.logger.info("Found #{errors.size} bad requests")
    AdminMailer.new_bad_requests_tracked(errors).deliver_now

    Rails.logger.info("Done.")
  end
end
