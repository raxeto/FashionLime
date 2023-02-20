class RemoveColorsCodeNullConstraint < ActiveRecord::Migration
  def change
    change_column_null(:colors, :code, true)
  end
end
