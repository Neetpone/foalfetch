# frozen_string_literal: true
require 'redcarpet/render_strip'

class StoryRenderer
  def initialize(story)
    @story = story
  end

  def txt
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
    separator = '//-------------------------------------------------------//'

    # Title and author
    text = "#{separator}\n".dup
    text += "#{@story.title.center(separator.length, ' ')}\n"
    text += "#{"-by #{@story.author.name}-".center(separator.length, ' ')}\n"
    text += "#{separator}\n"

    # Chapters
    @story.chapters.each do |chapter|
      text += "#{separator}\n"
      text += "#{chapter.title.center(separator.length, ' ')}\n"
      text += "#{separator}\n"
      text += "#{markdown.render chapter.body}\n" # FIXME: My Markdown still has the title at the top for no reason.
    end

    text
  end

  def html
  end

  def epub
    Ebook::EpubGenerator.new(@story).generate
  end
end
