# frozen_string_literal: true
require 'open-uri'

# Handles proxying images from the FiMFiction CDN and caching them locally, in case they disappear.
class ImagesController < ApplicationController
  # noinspection RubyMismatchedArgumentType
  def show
    url = params[:url]
    parsed = URI.parse(url)

    if parsed.host != 'cdn-img.fimfiction.net'
      render nothing: true, status: :bad_request
      return
    end

    ext = File.extname(url)
    hash = Digest::SHA256.hexdigest(url)
    path = Rails.public_path.join('cached-images', hash + ext)
    content_type = nil

    if File.exist? path
      content_type = Marcel::MimeType.for Pathname.new(path)
    else
      content_type, body = fetch_image parsed
      File.binwrite path, body
    end

    response.headers['Cache-Control'] = 'public'
    send_file path, disposition: :inline, type: content_type
  end

  private

  def fetch_image(uri)
    response = Net::HTTP.get_response(uri)

    [response['Content-Type'], response.body]
  end
end
