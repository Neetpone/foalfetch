require 'redcarpet'

class ChaptersController < ApplicationController
  def show
    @story = Story.find(params[:story_id])
    @chapter = @story.chapters.find_by(number: params[:id])

    @rendered_html = markdown.render(@chapter.body)
  end

  private
  def markdown
    @@markdown ||=
      Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end
end
