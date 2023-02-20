module Modules
  module PublicUserModel

    def user_full_name
     "#{user_first_name || user.first_name} #{user_last_name || user.last_name} (#{user.try(:username) || "гост"})" 
    end

  end
end
