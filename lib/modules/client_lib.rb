module Modules
  module ClientLib

    include UserSessionLib

    protected

      def current_or_guest_user
        if user_signed_in?
          current_user
        else
          guest_user
        end
      end

      def current_profile
        current_or_guest_user.profile
      end

      def current_cart
        current_or_guest_user.cart
      end

      def init_user
        if user_signed_in?
          if session_has_guest_user?
            if session_guest_user_id != current_user.id
              User.transfer_guest_data(session_guest_user_id, current_user.id)
            end

            delete_guest_user();
          end
        elsif !session_has_guest_user? || !User.exists?(session_guest_user_id)
          create_guest_user();
        end
      end

      def create_guest_user
        user_id = User.create_guest_user().id
        save_guest_user_id_to_session(user_id)
      end

      def delete_guest_user
        # we don't transfer the confidential info like orders etc. so we have to keep the user in the db
        # puts("DELETE USER WITH ID #{session_guest_user_id}")
        # begin
        #   User.destroy(session_guest_user_id)
        # end

        nil_session_guest_user();
      end

      def guest_user
        User.find(session_guest_user_id)
      end

      def authenticate_as_non_guest
        if session_has_guest_user?
          head(403)
        end
      end

      def current_user_admin?
        user_signed_in? && current_user.admin?
      end

      # Not used for now.
      def is_active_guest?
        if session_has_guest_user?
          guest = User.find_by(id: session_guest_user_id)
          return guest.present? && guest.active?
        end
        return false
      end
  end
end
