class TempNullableBody < ActiveRecord::Migration[7.0]
  def change
    change_column_null :chapters, :body, true
  end
end
