class RegisteredUserGuest < ActiveRecord::Base

  # Relations
  belongs_to :user, class_name: "User"
  belongs_to :guest, class_name: "User"
  
end
