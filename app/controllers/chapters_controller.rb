class ChaptersController < ApplicationController
  def show
    @story = Story.find(params[:story_id])
    @chapter = @story.chapters.find_by(number: params[:id])
  end
end
