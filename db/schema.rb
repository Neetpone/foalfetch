# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_04_02_172140) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "story_completion_status", ["hiatus", "incomplete", "complete", "cancelled"]
  create_enum "story_content_rating", ["teen", "everyone", "mature"]

  create_table "authors", force: :cascade do |t|
    t.text "name", null: false
    t.integer "num_blog_posts", default: 0, null: false
    t.integer "num_followers", default: 0, null: false
    t.text "avatar"
    t.text "bio_html"
    t.datetime "date_joined", null: false
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "story_id", null: false
    t.integer "number", default: 1, null: false
    t.datetime "date_published", null: false
    t.datetime "date_modified"
    t.integer "num_views", default: 0, null: false
    t.integer "num_words", null: false
    t.text "title", null: false
    t.text "body"
    t.index ["story_id"], name: "index_chapters_on_story_id"
  end

  create_table "stories", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.integer "color"
    t.text "completion_status"
    t.text "content_rating"
    t.text "cover_image"
    t.datetime "date_published", null: false
    t.datetime "date_updated"
    t.datetime "date_modified"
    t.text "description_html"
    t.integer "num_comments", default: 0, null: false
    t.integer "num_views", default: 0, null: false
    t.integer "num_words", null: false
    t.integer "prequel"
    t.integer "rating", null: false
    t.text "short_description"
    t.text "title", null: false
    t.integer "total_num_views", default: 0, null: false
    t.index ["author_id"], name: "index_stories_on_author_id"
  end

  create_table "story_taggings", id: false, force: :cascade do |t|
    t.bigint "story_id", null: false
    t.bigint "tag_id", null: false
    t.index ["story_id"], name: "index_story_taggings_on_story_id"
    t.index ["tag_id"], name: "index_story_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.text "name", null: false
    t.text "old_id"
    t.text "type", null: false
  end

end
