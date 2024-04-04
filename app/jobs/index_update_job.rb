# frozen_string_literal: true

class IndexUpdateJob < ApplicationJob
  queue_as :high
  def perform(cls, id)
    obj = cls.constantize.find(id)
    obj&.update_index(defer: false)
  rescue StandardError => e
    Rails.logger.error e.message
  end
end
