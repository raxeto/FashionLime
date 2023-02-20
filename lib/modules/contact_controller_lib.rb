module Modules
  module ContactControllerLib

    extend ActiveSupport::Concern

    included do
      
      append_before_filter :load_user

      def new
        @contact_inquiry = @user.contact_inquiries.build({
          :name => (@user.first_name + ' ' + @user.last_name).squish,
          :email => @user.email
          })
      end

      def create
        @contact_inquiry = @user.contact_inquiries.build(contact_inquiry_params)
        if !@contact_inquiry.save
          render :new
          return
        end

        ContactMailer.new_inquiry(@contact_inquiry).deliver_now
        redirect_to after_create_path, notice: 'Запитването Ви беше направено. Ще се свържем с Вас възможно най-скоро на посочения имейл адрес.'
      end

      protected

      def sections
        [:contact]
      end

      def contact_inquiry_params
        params.require(:contact_inquiry).permit(:name, :email, :subject, :message)
      end

      def load_user
        @user = current_or_guest_user
      end

    end

  end
end
