# frozen_string_literal: true
class ApplicationController < ActionController::Base
  before_action :start_timer
  before_action :count_visit
  before_action :setup_pagination_and_tags

  private

  def start_timer
    @start_time = Time.zone.now
  end

  def count_visit
    key = "visit-counter/#{Digest::SHA2.hexdigest(request.remote_ip)}"
    visited_today = $redis.get(key).present?
    $redis.setex(key, 1.day.in_seconds, '1') unless visited_today

    VisitCount.transaction do
      visit_count = VisitCount.for_today
      visit_count.update!(
        count: visit_count.count + 1
      ) unless visited_today
      @today_visit_count = visit_count.count
      @total_visit_count = Rails.cache.fetch('total_visits', expires_in: 1.hour) { VisitCount.sum(:count) }
    end
  end

  def setup_pagination_and_tags
    @per_page = 15
    per_page = params[:per_page]
    if per_page
      per_page = per_page.to_i
      @per_page = per_page if per_page.between? 1, 50
    end

    @page_num = params[:page].to_i
  end
end
