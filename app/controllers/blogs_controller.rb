# frozen_string_literal: true
class BlogsController < ApplicationController
  def index
    @blogs = Blog.order(created_at: :desc)
  end
end
