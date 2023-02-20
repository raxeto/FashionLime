require 'net/imap'

desc "Scans the auto mailbox for emails that bounced. Then disables mail
  promotions for the users that have those emails."
task :clean_undeliverable_emails => "setup:fashionlime" do
  imap = Net::IMAP.new('alfa.superhosting.bg', ssl: true)
  imap.login('no-reply@fashionlime.bg', Rails.application.secrets.no_reply_email_password)
  imap.select('INBOX')
  deleted = false

  for message_id in imap.search(['ALL'])
    body = imap.fetch(message_id, 'RFC822.TEXT')[0].attr['RFC822.TEXT']
    md = body.match(/Final-Recipient: rfc822;(.*)$/)

    unless md.nil?
      email = md[1].strip
      Rails.logger.info("Bad email: #{email}")

      user = User.find_by(email: email)
      user.update_attribute(:email_promotions, false) unless user.nil?

      subscriber = NewsletterSubscriber.find_by(email: email)
      subscriber.update_attribute(:active, 0) unless subscriber.nil?

      imap.copy(message_id, 'INBOX.Trash')
      imap.store(message_id, '+FLAGS', [:Deleted])
      deleted = true
    end
  end

  if deleted
    imap.expunge
  end

  imap.logout
  imap.disconnect
end
