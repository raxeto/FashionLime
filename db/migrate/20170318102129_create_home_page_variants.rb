class CreateHomePageVariants < ActiveRecord::Migration
  def change
    create_table :home_page_variants do |t|
      t.timestamps null: false
    end
  end
end
