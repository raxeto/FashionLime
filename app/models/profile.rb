class Profile < ActiveRecord::Base

  # Relations
  belongs_to :owner, polymorphic: true
  has_many   :ratings

  def name
    owner.try(:name) || owner.try(:username)
  end

end
