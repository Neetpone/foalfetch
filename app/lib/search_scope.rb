# frozen_string_literal: true
class SearchScope
  attr_reader :search_params, :scope_key, :scope_loaded, :scope_invalid

  def initialize(params, search_params = nil)
    @scope_key = SecureRandom.hex 16
    @scope_loaded = false

    if search_params
      @search_params = search_params
      self.persist
    elsif params
      self.load_from_params(params)
    end
  end

  private

  def load_from_params(params)
    if params[:scope].present?
      result = $redis.get("search_scope/#{params[:scope]}")
      if result.present?
        @search_params = JSON.parse(result, symbolize_names: true)
        @scope_key = params[:scope]
        @scope_loaded = true
        self.persist # refresh the expiry
      else
        @scope_invalid = true
      end
    else
      @search_params = params.permit!.to_h.symbolize_keys
      self.persist
    end
  end

  def persist
    # Nice long expiry so nobody's search disappears if they don't touch it for awhile.
    $redis.setex("search_scope/#{@scope_key}", 1.week.in_seconds, JSON.dump(@search_params))
  end
end
