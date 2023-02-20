namespace :check do
  desc "Reads the production logs and scans for requests with errors (DEPRECATED)"
  task :errors => "setup:fashionlime" do
    t = Time.now
    scan_logs_for_errors(t)
  end

  def parse_line_for_time(line)
    begin
      # 2017-04-07T06:37:06.350009 #11718
      # 07/Apr/2017:10:51:07 +0300
      d = DateTime.strptime(line[4..22], "%Y-%m-%dT%H:%M:%S")
      d = d.change(:offset => "+0300")
      return d
    rescue Exception => e
      Rails.logger.error("Failed parsing the line '#{line}'  #{e}")
      return nil
    end
  end

  def scan_logs_for_errors(curr_time)
    Rails.logger.info("Checking logs for #{curr_time}")
    log_file = "#{Dir.home}/web/shared/log/production.log"
    errors = []
    checked = 0

    File.readlines(log_file).reverse_each do |l|
      line_time = parse_line_for_time(l)
      if line_time.present? && is_line_too_old(line_time, curr_time)
        break
      end

      if /error|warning/i.match(l)
        if l.include?('Rendered errors/show') || l.include?('ErrorsController') || l.include?('RoutingError')
          Rails.logger.info("Skipping line #{l}")
          next
        end
        errors << "Line with error: #{l}"
      end

      checked += 1
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
