# frozen_string_literal: true
# This whole class is a giant mess but I coded it fast so give me a break.
class SearchController < ApplicationController
  ALLOWED_SORT_DIRS = %i[asc desc]
  ALLOWED_SORT_FIELDS = %i[title author date_published date_updated num_words rating rel]

  before_action :load_tags

  def index
    @search_params = {}
  end

  def search
    # unless params[:scope]
    #   return redirect_to root_path
    # end

    @scope = SearchScope.new(params)

    # The scope is valid if was successfully used to load the existing search params
    if @scope.scope_invalid
      return redirect_to(root_path)
    elsif !@scope.scope_loaded
      return redirect_to(search_path(scope: @scope.scope_key))
    end

    @search_params = @scope.search_params

    using_random = @search_params[:luck].present?

    # This was mainly written this way to match the way FiMFetch's query interface looks, without using JS.
    # I should do a Derpibooru-esque textual search system sometime.
    @search = StoryFinder.new(@search_params).find(
      per_page: @per_page,
      page:     @page_num
    ) do |s|
      # tags -> match any of the included tags, exclude any of the excluded tags
      tag_musts, tag_must_nots = parse_tag_queries
      boolses = {}

      boolses[:must] = (
        tag_musts.map { |t| { term: { tags: t } } }
      ) if tag_musts.any?

      boolses[:must_not] = (
        tag_must_nots.map { |t| { term: { tags: t } } }
      ) if tag_must_nots.any?

      s.add_query(bool: boolses) if boolses.any?
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
    tag_searches = "#{@search_params[:tags]},#{@search_params[:characters]}".split(',').compact_blank

    [
      tag_searches.reject { |t| t[0] == '-' },
      tag_searches.select { |t| t[0] == '-' }
                  .pluck(1..)
    ]
  end

  def parse_sort
    sf = ALLOWED_SORT_FIELDS.detect { |f| @search_params[:sf] == f.to_s } || :date_updated
    sd = ALLOWED_SORT_DIRS.detect { |d| @search_params[:sd] == d.to_s } || :desc

    # we need to sort on the keyword versions of text fields, to avoid using fielddata.
    sf = case sf
           when :rel
             :_score
           when :title
             :title_keyword
           when :author
             :author_keyword
           else
             sf
         end

    {sf => sd}
  end
end
