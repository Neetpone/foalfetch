# This whole class is a giant mess but I coded it fast so give me a break.
class SearchController < ApplicationController
  ALLOWED_SORT_DIRS = [:asc, :desc]
  ALLOWED_SORT_FIELDS = [:title, :author, :date_published, :date_updated, :num_words, :rel]

  before_action :load_tags

  def index
    @search_params = {}
  end

  def search
    unless setup_scope
      return
    end

    using_random = @search_params['luck'].present?

    # This was mainly written this way to match the way FiMFetch's query interface looks, without using JS.
    # I should do a Derpibooru-esque textual search system sometime.
    @search = Story.fancy_search(
      per_page: @per_page,
      page:     @page_num
    ) do |s|
      s.add_query(match: { title: { query: @search_params['q'], operator: :and } }) if @search_params['q'].present?
      s.add_query(match: { author: { query: @search_params['author'], operator: :and } }) if @search_params['author'].present?

      # ratings -> match stories with any of them
      s.add_filter(bool: {
        should: @search_params['ratings'].keys.map { |k| { term: { content_rating: k } } }
      }) if @search_params['ratings'].present?

      # completeness -> match stories with any of them
      s.add_filter(bool: {
        should: @search_params['state'].keys.map { |k| { term: { completion_status: k } } }
      }) if @search_params['state'].present?

      # tags -> match any of the included tags, exclude any of the excluded tags
      tag_musts, tag_must_nots = parse_tag_queries

      s.add_filter(terms: { tags: tag_musts }) if tag_musts.any?
      s.add_filter(bool: { must_not: { terms: { tags: tag_must_nots } } }) if tag_must_nots.any?

      # sort direction
      if using_random
        s.add_sort _random: :desc
      else
        s.add_sort parse_sort
      end
    end

    if using_random && @search.total_count > 0
      redirect_to story_path(@search.records[0])
      return
    end

    @records = @search.records
  end

  private

  def load_tags
    @character_tags = Tag.where(type: 'character').order(name: :asc).pluck(:name)
    @other_tags = Tag.where.not(type: 'character').order(name: :asc).pluck(:name)
  end

  # returns: [included tags, excluded tags]
  def parse_tag_queries
    tag_searches = (@search_params['tags'] + ',' + @search_params['characters']).split(',').reject &:blank?

    [tag_searches.select { |t| t[0] != '-' }, tag_searches.select { |t| t[0] == '-' }]
  end

  def parse_sort
    sf = ALLOWED_SORT_FIELDS.detect { |f| @search_params['sf'] == f.to_s } || :date_updated
    sd = ALLOWED_SORT_DIRS.detect { |d| @search_params['sd'] == d.to_s } || :desc

    # we need to sort on the keyword versions of text fields, to avoid using fielddata.
    sf = case sf
         when :rel then
           :_score
         when :title then
           :title_keyword
         when :author then
           :author_keyword
         else
           sf
         end

    {sf => sd}
  end

  # FIXME: This is some of the worst Ruby code I have ever written.
  def setup_scope
    @scope_key = Random.hex(16)
    scope_valid = false

    # scope passed, try to look it up in redis and use the search params from it
    if params[:scope].present?
      result = $redis.get("search_scope/#{params[:scope]}")
      if result.present?
        @search_params = JSON.load(result)
        @scope_key = params[:scope]
        scope_valid = true
      else
        redirect_to '/'
        return false
      end
    else
      @search_params = params
    end

    # you can't JSON.dump a Parameters
    if @search_params.is_a? ActionController::Parameters
      @search_params = @search_params.permit!.to_h
    end
    $redis.setex("search_scope/#{@scope_key}", 3600, JSON.dump(@search_params))

    # if the scope was invalid (no key passed, or invalid key passed), redirect to the results page
    # with the new key we just generated for the params we had.
    unless scope_valid
      redirect_to "/search?scope=#{@scope_key}"
      return false
    end

    true
  end
end
