class AddReplyMessageToContactInquiries < ActiveRecord::Migration
  def change
    change_table(:contact_inquiries) do |t|
      t.text    :reply_message, after: :message
    end
  end
end
