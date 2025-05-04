# frozen_string_literal: true
require 'redcarpet'

class ChaptersController < ApplicationController
  def show
    @story = Story.find(params[:story_id])

    if params[:id].to_i == 0
      @full_story = true
      @rendered_html = render_to_string partial: 'stories/full_story', :locals => { story: @story  }
    else
      @chapter = @story.chapters.find_by(number: params[:id])

      @rendered_html = Ebook::EpubGenerator.render_chapter(@chapter)
    end
  end
end
