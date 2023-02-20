class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.string     :name, limit: 1024
      t.attachment :logo
      t.float      :rating
      t.string     :website, limit: 4096
      t.text       :description
      t.text       :return_policy
      t.integer    :status, null: false, default: 1
      t.timestamps null: false
    end

  end
end
