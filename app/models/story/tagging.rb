class Story::Tagging < ApplicationRecord
  belongs_to :story
  belongs_to :tag

  validates :tag, uniqueness: { scope: [:story_id] }
end