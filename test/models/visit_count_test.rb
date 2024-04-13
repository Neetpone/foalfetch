# == Schema Information
#
# Table name: visit_counts
#
#  id    :bigint           not null, primary key
#  count :integer          default(0), not null
#  date  :date             not null
#
require "test_helper"

class VisitCountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
