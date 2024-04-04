# frozen_string_literal: true
# == Schema Information
#
# Table name: tags
#
#  id     :bigint           not null, primary key
#  name   :text             not null
#  type   :text             not null
#  old_id :text
#
require 'test_helper'

class TagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
