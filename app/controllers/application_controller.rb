class ApplicationController < ActionController::Base
  before_action :start_timer
  before_action :setup_pagination_and_tags

  private

  def start_timer
    @start_time = Time.zone.now
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
