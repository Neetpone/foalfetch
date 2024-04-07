# frozen_string_literal: true
class AuthorsController < ApplicationController
  def show
    author = Author.select(:name).find(params[:id])
    scope = SearchScope.new(nil, { author: author.name })

    redirect_to "/search?scope=#{scope.scope_key}"
  end
end
