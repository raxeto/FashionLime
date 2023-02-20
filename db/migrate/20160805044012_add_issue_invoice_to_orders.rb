class AddIssueInvoiceToOrders < ActiveRecord::Migration
  def change
    change_table(:orders) do |t|
      t.integer    :issue_invoice, null: false, default: 0, after: :only_business_days
    end
  end
end
