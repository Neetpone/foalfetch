class AddOriginAndDeletedAtOriginToStories < ActiveRecord::Migration[7.0]
  def change
    add_column :stories, :origin, :string, null: false, default: 'fimfiction'
    add_column :stories, :deleted_at_origin, :boolean, null: false, default: false
  end
end
