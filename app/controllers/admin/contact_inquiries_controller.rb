class Admin::ContactInquiriesController < AdminController

  def index
    @inquiry_models = ContactInquiry.includes(:user).order(:status, :created_at)
    @inquiries = @inquiry_models.map {
      |i| {
        :id => i.id,
        :username => i.user.try(:username),
        :name => i.name,
        :email => i.email,
        :status => i.status,
        :subject => i.subject,
        :message => truncate_string(i.message, 70),
        :reply_message => truncate_string(i.reply_message, 70),
        :created_at => date_time_to_s(i.created_at)
      }.to_json
    }
  end

  def edit
    @inquiry = ContactInquiry.find(params[:id])
  end

  def update
    @inquiry = ContactInquiry.find(params[:id])
    pars = inquiry_params

    reply_updated = pars[:reply_message].present?
    if reply_updated
      pars[:status] = ContactInquiry.statuses[:replied]
    end
    unless @inquiry.update_attributes(pars)
      render :edit
      return
    end
    if reply_updated
      ContactMailer.reply_inquiry(@inquiry, current_user).deliver_now
    end
    redirect_to admin_contact_inquiries_path, notice: 'Inquiry edited successfully.'
  end

  def set_not_valid
    @inquiry = ContactInquiry.find(params[:id])
    if @inquiry.update_attributes(:status => ContactInquiry.statuses[:not_valid])
      redirect_to admin_contact_inquiries_path, notice: 'Inquiry marked as NOT valid.'
    else
      redirect_to admin_contact_inquiries_path, alert: 'Error setting status to not valid.'
    end
  end

  private

  def inquiry_params
    params.require(:contact_inquiry).permit(:reply_message)
  end

end
