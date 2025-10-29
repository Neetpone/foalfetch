# frozen_string_literal: true
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.3'

gem 'rails', '~> 8.1.1'
gem 'sprockets-rails'

# Database stuff
gem 'pg', '~> 1.1'
gem 'redis'

# Views
gem 'kaminari' # Must be included before ElasticSearch
gem 'redcarpet'
gem 'sassc'
gem 'slim-rails'

# Search
gem 'elasticsearch-model'
gem 'fancy_searchable', github: 'Twibooru/fancy_searchable', ref: '40687c9'
gem 'model-msearch'

# Programs
gem 'puma', '~> 6.0'
gem 'sidekiq'

# Other stuff
gem 'activeadmin'
gem 'devise'
gem 'gepub'
gem 'marcel'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

# Use Sass to process CSS
# gem "sassc-rails"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'simplecov'
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
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end
