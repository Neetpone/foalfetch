# frozen_string_literal: true
class RecountWordsJob < ApplicationJob
  def perform(*)
    Story.find_each do |story|
      word_count = 0
      story.chapters.each do |chapter|
        next unless chapter.body

        count = chapter.body.split.size
        chapter.update_columns(
          num_words: count
        )
        word_count += count
      end

      story.update_columns(
        num_words: word_count
      )
    end
  end
end
