# frozen_string_literal: true
class Stories::DownloadsController < ApplicationController
  MIME_TYPES = {
    txt: 'text/plain',
    html: 'text/html',
    epub: 'application/x-epub'
  }.freeze

  def show
    @story = Story.find(params[:story_id])

    format = MIME_TYPES.keys.detect { |fmt| fmt.to_s == params[:fmt] } || :text
    renderer = StoryRenderer.new @story

    send_data renderer.send(format), type: MIME_TYPES[format], disposition: :attachment, filename: "#{@story.title}.#{format}"
  end
end
