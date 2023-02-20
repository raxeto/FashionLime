class AddPersonalInformationToUsers < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.string     :first_name, limit: 1024, default: ''
      t.string     :last_name, limit: 1024, default: ''
      t.string     :phone
      t.float      :rating
      t.string     :gender, limit: 1
      t.date       :birth_date
      t.attachment :avatar
    end
  end
end
