# == Schema Information
#
# Table name: tags
#
#  id     :bigint           not null, primary key
#  name   :text             not null
#  type   :text             not null
#  old_id :text
#
class Tag < ApplicationRecord
  # needed because we have a column called 'type'
  self.inheritance_column = '_inheritance_column'
end
