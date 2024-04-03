require 'redcarpet'

class ChaptersController < ApplicationController
  def show
    @story = Story.find(params[:story_id])
    @chapter = @story.chapters.find_by(number: params[:id])

    @rendered_html = render_story
  end

  private

  def render_story
    body = @chapter.body
    body.lstrip!
    body = body.split "\n"

    # This is fucking bad, this gets rid of the redundant title - this should be fixed upstairs,
    # in the actual generation of the Markdown.
    if body.length >= 2 && body[0] == @chapter.title && body[1].length > 0 && body[1][0] == '='
      body = body[2..]
    end

    markdown.render body.join("\n")
  end

  def markdown
    @@markdown ||=
      Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end
end
