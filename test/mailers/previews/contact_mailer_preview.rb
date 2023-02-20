# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview

  def new_inquiry
    contact_inquiry = ContactInquiry.last
    ContactMailer.new_inquiry(contact_inquiry)
  end

  def reply_inquiry
    contact_inquiry = ContactInquiry.first
    admin = User.find(1)
    ContactMailer.reply_inquiry(contact_inquiry, admin)
  end

end
