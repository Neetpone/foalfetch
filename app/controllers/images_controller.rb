require 'open-uri'

# Handles proxying images from the FiMFiction CDN and caching them locally, in case they disappear.
class ImagesController < ApplicationController
  #noinspection RubyMismatchedArgumentType
  def show
    url = params[:url]
    parsed = URI.parse(url)

    if parsed.host != 'cdn-img.fimfiction.net'
      render nothing: true, status: :bad_request
      return
    end

    ext = File.extname(url)
    hash = Digest::SHA256.hexdigest(url)
    path = Rails.root.join('public', 'cached-images', hash + ext)
    our_url = '/cached-images/' + hash + ext

    if File.exist? path
      redirect_to our_url
      return
    end

    File.open(path, 'wb') do |fp|
       fp.write(Net::HTTP.get(parsed))
    end

    redirect_to our_url
  end
end
