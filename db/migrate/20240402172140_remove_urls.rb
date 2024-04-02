class RemoveUrls < ActiveRecord::Migration[7.0]
  def change
    remove_column :stories, :url, :text
    remove_column :chapters, :url, :text
    remove_column :tags, :url, :text
    remove_column :authors, :url, :text
  end
end
