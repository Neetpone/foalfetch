# frozen_string_literal: true
class Stories::DownloadsController < ApplicationController
  MIME_TYPES = {
    text: 'text/plain',
    html: 'text/html',
    epub: 'application/x-epub'
  }.freeze

  def show
    @story = Story.find(params[:story_id])

    format = MIME_TYPES.keys.detect { |fmt| fmt.to_s == params[:fmt] } || :text
    renderer = StoryRenderer.new @story

    render inline: renderer.send(format), content_type: MIME_TYPES[format], content_disposition: 'attachment'
  end
end
