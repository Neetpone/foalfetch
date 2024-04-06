class CreateBlogs < ActiveRecord::Migration[7.0]
  def change
    create_table :blogs do |t|
      t.timestamps null: false
      t.text :title, null: false
      t.text :body, null: false
    end
  end
end
