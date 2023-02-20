module Modules
  module PasswordManagingController

    extend ActiveSupport::Concern

    included do
      before_action :load_min_password_len
    end

    protected

    def load_min_password_len
      @minimum_password_length = User.password_length.min
    end


  end
end
