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

class Blog < ApplicationRecord
  validates :title, presence: true, length: { maximum: 128 }
  validates :body, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[body created_at id id_value title updated_at]
  end
end
