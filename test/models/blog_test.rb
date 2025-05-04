# frozen_string_literal: true
# == Schema Information
#
# Table name: blogs
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  title      :text             not null
#  body       :text             not null
#

require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
