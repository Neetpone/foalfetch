# frozen_string_literal: true
module StoryIndex
  def self.included(base)
    base.settings index: { number_of_shards: 5, max_result_window: 10_000_000 } do
      mappings dynamic: false do
        indexes :id,                type: 'integer'
        indexes :author_id,         type: 'keyword'
        indexes :completion_status, type: 'keyword'
        indexes :content_rating,    type: 'keyword'
        indexes :date_published,    type: 'date'
        indexes :date_updated,      type: 'date'
        indexes :date_modified,     type: 'date'
        indexes :num_comments,      type: 'integer'
        indexes :num_views,         type: 'integer'
        indexes :num_words,         type: 'integer'
        indexes :rating,            type: 'integer'
        indexes :short_description, type: 'text', analyzer: 'snowball'
        indexes :description_html,  type: 'text', analyzer: 'snowball'
        indexes :title,             type: 'text', analyzer: 'snowball'
        indexes :title_keyword,     type: 'keyword'
        indexes :author,            type: 'text', analyzer: 'snowball'
        indexes :author_keyword,    type: 'keyword'
        indexes :tags,              type: 'keyword'
      end
    end

    base.extend ClassMethods
  end

  module ClassMethods
    def default_sort(_options = {})
      [date_published: :desc]
    end

    def allowed_search_fields(_access_options = {})
      %i[title completion_status content_rating date_published date_updated date_modified
         num_comments num_views num_words rating short_description description_html
         title title_keyword tags author author_keyword]
    end
  end

  def as_json(*)
    {
      id: id,
      author_id: author.id,
      completion_status: completion_status,
      content_rating: content_rating,
      date_published: date_published,
      date_updated: date_updated,
      date_modified: date_modified,
      num_comments: num_comments,
      num_views: num_views,
      num_words: num_words,
      rating: rating,
      short_description: short_description,
      description_html: description_html,
      title: title,
      title_keyword: title,
      tags: tags.map(&:name),
      author: author.name,
      author_keyword: author.name
    }
  end

  def as_indexed_json(*)
    as_json
  end
end
