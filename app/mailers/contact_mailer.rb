class ContactMailer < ApplicationMailer

  def new_inquiry(contact_inquiry)
    subject = I18n.t('mailers.contact.new_inquiry.subject')
    email = Conf.contact.clients_email
    @contact_inquiry = contact_inquiry
    mail(to: email, subject: subject)
  end

  def reply_inquiry(contact_inquiry, admin_user)
    subject = I18n.t('mailers.contact.reply_inquiry.subject')
    # from_email = admin_user.email
    to_email = contact_inquiry.email
    @contact_inquiry = contact_inquiry
    # mail(from: from_email, to: to_email, subject: subject)
    mail(to: to_email, subject: subject)
  end

end
