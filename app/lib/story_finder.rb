# frozen_string_literal: true
class StoryFinder
  # key is the params scalar field, value is the ES document field to search on
  QUERIES = {
    q:      :title,
    author: :author
  }.freeze

  # key is the params array field, value is the query type and the ES document field to search on.
  FILTERS = {
    ratings: { type: :should, field: :content_rating },
    state:   { type: :should, field: :completion_status }
  }.freeze

  def initialize(params)
    @params = params
  end

  def find(opts)
    Story.fancy_search(opts) do |s|
      build_queries(s)
      build_filters(s)

      yield s if block_given?
    end
  end

  private

  # @param s FancySearchable::FancySearchableOptions
  def build_queries(s)
    QUERIES.each do |param, field|
      s.add_query match: { field => { query: @params[param], operator: :and } } if @params[param].present?
    end
  end

  # @param s FancySearchable::FancySearchableOptions
  def build_filters(s)
    FILTERS.each do |param, opts|
      s.add_filter(bool: {
        opts[:type] => @params[param].keys.map { |k| { term: { opts[:field] => k } } }
      }) if @params[param].present?
    end
  end
end
