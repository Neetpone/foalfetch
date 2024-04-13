# == Schema Information
#
# Table name: visit_counts
#
#  id    :bigint           not null, primary key
#  count :integer          default(0), not null
#  date  :date             not null
#
class VisitCount < ApplicationRecord
  def self.for_today
    VisitCount.find_or_create_by(date: Time.zone.today)
  end
end
