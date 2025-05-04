# frozen_string_literal: true
require 'ostruct'
require 'redcarpet/render_strip'

class StoryRenderer
  TEMPLATE_DIRECTORY = Rails.root.join('app/lib/story_renderer')

  def initialize(story)
    @story = story
  end

  def txt
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
    separator = '//-------------------------------------------------------//'

    # Title and author
    text = "#{separator}\n"
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
    context = OpenStruct.new(
      story: @story,
      chapters: @story.chapters.map do |chapter|
        OpenStruct.new(
          ordinal: chapter.number,
          title: chapter.title,
          number: chapter.number,
          rendered: Ebook::EpubGenerator.render_chapter(chapter)
        )
      end
    )

    render_template('story', context)
  end

  def epub
    Ebook::EpubGenerator.new(@story).generate
  end

  private

  def render_template(name, context)
    Slim::Template.new(TEMPLATE_DIRECTORY.join("templates/#{name}.html.slim")).render(context)
  end
end
