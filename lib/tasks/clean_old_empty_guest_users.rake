namespace :clean do
  desc "Cleans the old guest users that haven't made any actions"
  task :old_guests => "setup:fashionlime" do
    Rails.logger.info("Cleaning old guest users...")
    t = Time.now
    clean_guests(t - 20.days)
  end

  def clean_guests(t)
    ids_to_delete = []
    User.includes(:orders, { cart: :cart_details }, :user_roles, :outfits).guests.where('users.updated_at < ?', t).limit(1000).each do |u|
      ids_to_delete << u.id if u.is_empty_guest_user?
    end

    Rails.logger.info("#{ids_to_delete.size} guests will be deleted. IDs: #{ids_to_delete}")
    unless ids_to_delete.empty?
      User.includes(:user_roles, :addresses, :merchant_user, { cart: :cart_details }, :profile).destroy(ids_to_delete)
    end

    Rails.logger.info("Guests deleted successfully.")
  end
end
