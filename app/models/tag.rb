class Tag < ApplicationRecord
  # needed because we have a column called 'type'
  self.inheritance_column = '_inheritance_column'
end
