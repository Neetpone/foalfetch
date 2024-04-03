# == Schema Information
#
# Table name: chapters
#
#  id             :bigint           not null, primary key
#  body           :text
#  date_modified  :datetime
#  date_published :datetime         not null
#  num_views      :integer          default(0), not null
#  num_words      :integer
#  number         :integer          default(1), not null
#  title          :text             not null
#  story_id       :bigint           not null
#
# Indexes
#
#  index_chapters_on_story_id  (story_id)
#
require "test_helper"

class ChapterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
