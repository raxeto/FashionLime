class NewsletterSubscriber < ActiveRecord::Base

  # Relations
  belongs_to :user

  # Validations
  validates :email, email: true, presence: true
  validates_presence_of :user
  validates_presence_of :active

  # Scopes
  scope :subscribed, -> { where(active: 1) }

end
