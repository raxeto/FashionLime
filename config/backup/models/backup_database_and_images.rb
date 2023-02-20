##
#
# $ backup perform -t backup_database_and_images -c /Users/acev/Development/dressme/config/backup/config.rb'
#
Model.new(:backup_database_and_images, 'Create a full database backup and paperclip image files (stored in public/system.') do
  db_config = YAML.load_file('/home/deploy/web/shared/config/database.yml')['production']

  archive :images do |archive|
    archive.add "/home/deploy/web/shared/public/system/"
  end

  database MySQL do |db|
    db.name           = db_config['database']
    db.username       = db_config['username']
    db.password       = db_config['password']
    db.host           = "localhost"
    db.additional_options = ["--single-transaction"]
  end

  ##
  # SCP (Secure Copy) [Storage]
  # Rali: Decide where to save them?
  # store_with SCP do |server|
  #   server.username   = "my_username"
  #   server.password   = "my_password"
  #   server.ip         = "0.0.0.0"
  #   server.port       = 22
  #   server.path       = "~/backups/"
  #   server.keep       = 5
  #   # server.keep       = Time.now - 2592000 # Remove all backups older than 1 month.

  #   # Additional options for the SSH connection.
  #   # server.ssh_options = {}
  # end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  # Store data in S3, so that we can recover if the disk fails.
  s3_config = YAML.load_file('/home/deploy/web/shared/config/s3.yml')['s3-credentials']
  store_with S3 do |s3|
    # AWS Credentials
    s3.access_key_id     = s3_config['access_key_id']
    s3.secret_access_key = s3_config['secret_access_key']
    # Or, to use an IAM Profile:
    # s3.use_iam_profile = true

    s3.region             = 'eu-central-1'
    s3.bucket             = 'fashionlime-backups'
    s3.path               = 'data'
  end

  # This backup target should be the prime one. Use it if we mess up the DB for any reason.
  store_with Local do |local|
    local.path       = "/home/deploy/web/backups"
    local.keep       = 5
  end

  ## TODO setup mail
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  # #
  notify_by Mail do |mail|
    mail.on_success           = false
    mail.on_warning           = true
    mail.on_failure           = true

    mail.from                 = "no-reply@fashionlime.bg"
    mail.to                   = "admin@fashionlime.bg"
    mail.cc                   = "ralica.peicheva@gmail.com"
    mail.reply_to             = "no-reply@fashionlime.bg"
    mail.address              = "mail.fashionlime.bg"
    mail.port                 = 465
    mail.domain               = "fashionlime.bg"
    mail.user_name            = "no-reply@fashionlime.bg"
    mail.password             = YAML.load_file('/home/deploy/web/shared/config/secrets.yml')['production']['no_reply_email_password']
    mail.authentication       = "plain"
    mail.encryption           = :tls
    mail.openssl_verify_mode  = 'none'
  end

end
