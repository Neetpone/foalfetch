require 'open-uri'

class ImagesController < ApplicationController
  def show
    url = params[:url]
    parsed = URI.parse(url)

    if parsed.host != 'cdn-img.fimfiction.net'
      render nothing: true, status: :bad_request
      return
    end

    hash = Digest::SHA256.hexdigest(url)
    path = Rails.root.join('public', 'cached-images', hash + File.extname(url))
    our_url = '/cached-images/' + hash + File.extname(url)

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
