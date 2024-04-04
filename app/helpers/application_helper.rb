# frozen_string_literal: true
module ApplicationHelper
  # https://infusion.media/content-marketing/how-to-calculate-reading-time/
  def reading_time(words)
    minutes = words / 200.0

    distance_of_time_in_words(minutes * 60.0)
  end

  def render_time
    diff = ((Time.zone.now - @start_time) * 1000.0).round(2)
    diff < 1000 ? "#{diff}ms" : "#{(diff / 1000.0).round(2)}s"
  rescue StandardError
    'unknown ms'
  end
end
