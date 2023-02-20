class CreateContactInquiries < ActiveRecord::Migration
  def change
    create_table :contact_inquiries do |t|
      t.references :user, null: false, index: true
      t.string     :name, limit: 1024, null: false
      t.string     :email, limit: 1024, null: false
      t.string     :subject, limit: 1024, null: false
      t.text       :message, null:false
      t.integer    :status, null: false, default: 1
      t.timestamps null: false
    end
  end
end
