class Story < ApplicationRecord
  include FancySearchable::Searchable
  include Indexable

  belongs_to :author
  has_many :chapters
  has_many :taggings, validate: false
  has_many :tags, through: :taggings, validate: false
end
