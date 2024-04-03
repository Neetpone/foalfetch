# == Schema Information
#
# Table name: stories
#
#  id                :bigint           not null, primary key
#  color             :integer
#  completion_status :text
#  content_rating    :text
#  cover_image       :text
#  date_modified     :datetime
#  date_published    :datetime         not null
#  date_updated      :datetime
#  description_html  :text
#  num_comments      :integer          default(0), not null
#  num_views         :integer          default(0), not null
#  num_words         :integer          not null
#  prequel           :integer
#  rating            :integer          not null
#  short_description :text
#  title             :text             not null
#  total_num_views   :integer          default(0), not null
#  author_id         :bigint           not null
#
# Indexes
#
#  index_stories_on_author_id  (author_id)
#
class Story < ApplicationRecord
  include FancySearchable::Searchable
  include Indexable

  belongs_to :author
  has_many :chapters
  has_many :taggings, validate: false
  has_many :tags, through: :taggings, validate: false
end
