class CreateTradeMarks < ActiveRecord::Migration
  def change
    create_table :trade_marks do |t|

      t.string     :name, limit: 1024
      t.attachment :logo
      t.timestamps null: false
    end
  end
end
