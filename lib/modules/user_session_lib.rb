module Modules
  module UserSessionLib

    protected

      # Saves the guest_user_id in the current session.
      def save_guest_user_id_to_session(user_id)
        session[:guest_user_id] = user_id
      end

      # Check if the session has guest user
      def session_has_guest_user?
        session.has_key?(:guest_user_id)
      end

      # Returns guest_user_id from the session
      def session_guest_user_id
        session[:guest_user_id]
      end

      # Clears guest_user_id
       def nil_session_guest_user
        session[:guest_user_id] = nil
      end

  end
end
