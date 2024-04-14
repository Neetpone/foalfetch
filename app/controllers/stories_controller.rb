# frozen_string_literal: true
class StoriesController < ApplicationController
  def index
  end

  def show
    @story = Story.find(params[:id])
    @chapters = @story.chapters.order(number: :asc)
    @normal_tags = @story.tags.where.not(type: 'character')
    @character_tags = @story.tags.where(type: 'character')
  end
end
