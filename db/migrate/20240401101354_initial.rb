class Initial < ActiveRecord::Migration[7.0]
  def change
    #create_enum :story_completion_status, %w[hiatus incomplete complete cancelled]
    #create_enum :story_content_rating, %w[teen everyone mature]

    create_table :authors do |t|
      t.text :name, null: false
      t.integer :num_blog_posts, null: false, default: 0
      t.integer :num_followers, null: false, default: 0
      t.text :avatar, null: true
      t.text :bio_html, null: true
      t.datetime :date_joined, null: false
      t.text :url, null: false
    end

    create_table :stories do |t|
      t.belongs_to :author, null: false
      t.integer :color, null: true
      # t.enum :completion_status, enum_type: 'story_completion_status', null: false
      # t.enum :content_rating, enum_type: 'story_content_rating', null: false
      t.text :completion_status
      t.text :content_rating
      t.text :cover_image, null: true
      t.datetime :date_published, null: false
      t.datetime :date_updated, null: true
      t.datetime :date_modified, null: true
      t.text :description_html, null: true
      t.integer :num_comments, null: false, default: 0
      t.integer :num_views, null: false, default: 0
      t.integer :num_words, null: false
      t.integer :prequel, null: true
      t.integer :rating, null: false
      t.text :short_description, null: true
      t.text :title, null: false
      t.integer :total_num_views, null: false, default: 0
      t.text :url, null: false
    end

    create_table :chapters do |t|
      t.belongs_to :story, null: false
      t.integer :number, null: false, default: 1
      t.datetime :date_published, null: false
      t.datetime :date_modified, null: true
      t.integer :num_views, null: false, default: 0
      t.integer :num_words, null: false
      t.text :title, null: false
      t.text :url, null: false
      t.text :body, null: false
    end

    create_table :tags do |t|
      t.text :name, null: false
      t.text :old_id, null: true
      t.text :url, null: false
      t.text :type, null: false
    end

    create_table :story_taggings, id: false, primary_key: [:story_id, :tag_id] do |t|
      t.belongs_to :story, null: false
      t.belongs_to :tag, null: false
    end
  end
end
