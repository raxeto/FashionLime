class AddReturnInstructionsAndPhoneToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :return_instructions, :text
    add_column :merchants, :phone, :string
  end
end
