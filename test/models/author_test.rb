# frozen_string_literal: true
# == Schema Information
#
# Table name: authors
#
#  id             :bigint           not null, primary key
#  avatar         :text
#  bio_html       :text
#  date_joined    :datetime         not null
#  name           :text             not null
#  num_blog_posts :integer          default(0), not null
#  num_followers  :integer          default(0), not null
#
require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
