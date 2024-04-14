# frozen_string_literal: true
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', '~> 7.0.8', '>= 7.0.8.1'
gem 'sprockets-rails'

# Database stuff
gem 'pg', '~> 1.1'
gem 'redis'

# Views
gem 'kaminari' # Must be included before ElasticSearch
gem 'redcarpet'
gem 'slim-rails'

# Search
gem 'elasticsearch-model'
gem 'fancy_searchable', github: 'Twibooru/fancy_searchable', ref: '40687c9'
gem 'model-msearch'

# Programs
gem 'puma', '~> 5.0'
gem 'sidekiq'

# Other stuff
gem 'gepub'
gem 'marcel'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

# Use Sass to process CSS
# gem "sassc-rails"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem 'annotate'
  gem 'bullet'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'web-console'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
end
