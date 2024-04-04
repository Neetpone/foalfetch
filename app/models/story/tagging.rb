# frozen_string_literal: true
# == Schema Information
#
# Table name: story_taggings
#
#  story_id :bigint           not null
#  tag_id   :bigint           not null
#
# Indexes
#
#  index_story_taggings_on_story_id  (story_id)
#  index_story_taggings_on_tag_id    (tag_id)
#
class Story::Tagging < ApplicationRecord
  belongs_to :story
  belongs_to :tag

  validates :tag, uniqueness: { scope: [:story_id] }
end
