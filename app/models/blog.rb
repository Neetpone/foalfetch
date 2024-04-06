# frozen_string_literal: true
# == Schema Information
#
# Table name: blogs
#
#  id         :bigint           not null, primary key
#  body       :text             not null
#  title      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Blog < ApplicationRecord
  validates :title, presence: true, length: { maximum: 128 }
  validates :body, presence: true
end
