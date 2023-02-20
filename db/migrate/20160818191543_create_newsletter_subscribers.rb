class CreateNewsletterSubscribers < ActiveRecord::Migration
  def change
    create_table :newsletter_subscribers do |t|
      t.string     :email, null: false, limit: 255
      t.references :user, null: false
      t.integer    :active, null: false, default: 1
      t.timestamps null: false
    end
    add_index :newsletter_subscribers, :email, :unique => true
  end
end
