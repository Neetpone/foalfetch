# frozen_string_literal: true
require 'redcarpet'

class ChaptersController < ApplicationController
  def show
    @story = Story.find(params[:story_id])
    @chapter = @story.chapters.find_by(number: params[:id])

    @rendered_html = StoryRenderer.render_chapter(@chapter)
  end
end
