class ContactInquiry < ActiveRecord::Base

  # Attributes
  enum status: { submited: 1, replied: 2, not_valid: 3 }

  # Relations
  belongs_to :user

  # Validations
  validates_presence_of :user
  validates_presence_of :name
  validates :email, email: true, presence: true
  validates_presence_of :subject
  validates_presence_of :message
  validates_presence_of :status

end
