# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.6'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password
# [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants
# [https://guides.rubyonrails.org/active_storage_overview.html
# transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS),
# making cross-origin AJAX possible
# gem "rack-cors"

# use `knock` for api token authentication
# gem 'knock', '~> 2.1.1'
gem 'knock', github: 'thegurucompany/knock'

gem 'tzinfo-data', '~> 1.2023.3'
# Use Active Storage variants
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS),
# making
# cross-origin AJAX possible
gem 'rack-cors', '~> 1.1.1'
# use `Airbrake-Errbit` for Error Reporting
gem 'airbrake', '~> 13.0.2'
# API Versioning
gem 'versionist', '~> 2.0.1'
# Serialization vs Presenters which lack docs.
gem 'active_model_serializers', '~> 0.10.12'
# use `dotenv-rails` for ENV variable management
gem 'dotenv-rails', '~> 2.8.1'
# use `kaminari` for ActiveRecord::Relation paging
gem 'kaminari', '~> 1.2.2'
# pundit for authorization
gem 'pundit', '~> 2.2.0'
# Use paranoia gem to provide safe/virtual deletion to selected models
gem 'paranoia', '~> 2.6.0'
# Pry
gem 'pry-rails', '~> 0.3.9'
# Use rest-client for API interactions
gem 'rest-client', '~> 2.1.0'
# Implements authentication
gem 'devise', '~> 4.9.2'
gem 'devise_token_auth', '~> 1.2.3'
# use papertrail for handle versions
gem 'paper_trail', '~> 12.1'
# use caxlsx for XLSX file creation
gem 'caxlsx', '~> 3.0.3'
gem 'redis', '~> 5.2.0'
# use sidekiq for background jobs
gem 'sidekiq', '~> 7.2.4'
# use sidekiq-cron for cron jobs
gem 'sidekiq-cron', '~> 1.12.0'
# use sidekiq-limit_fetch for concurrency management
gem 'sidekiq-limit_fetch', '~> 4.4.1'
# gems for ssh deploy support
gem 'bcrypt_pbkdf', '~> 1.1.0'
gem 'ed25519', '~> 1.3.0'
# capabilities for sorting and reordering a number of objects in a list
gem 'acts_as_list', '~> 0.9.19'
# WEBrick is capable of handling and processing incoming HTTP requests.
gem 'webrick', '~> 1.8.1'
# Use [neighbor] for vector support in ActiveRecord
gem 'neighbor', '~> 0.2.3'
# Use [openai] for Embeddings & Chat Prompts
gem 'ruby-openai', '~> 6.3.1'
# Use [text-extractor] for extracting text from files
gem 'text-extractor', github: 'thegurucompany/text-extractor'
# Use [puppeteer-ruby] for website scrapping
gem 'puppeteer-ruby', '~> 0.45.3'
# Use [nokogiri] for HTML and XML parsing
gem 'nokogiri', '~> 1.15.5'
# Use [rails-i18n] for internationalization
gem 'rails-i18n', '~> 7.0.0'
# Use [email_validator] for email validation
gem 'email_validator', '~> 2.2.4'
# use [rails-healthcheck] for health checks
gem 'rails-healthcheck', '~> 1.4.0'
# use [tiktoken_ruby] for tokenizing text for GPT models
gem 'tiktoken_ruby', '~> 0.0.9'
# use [redcarpet] for Markdown parsing
gem 'redcarpet', '~> 3.6.0'
# use [wicked_pdf] for generating PDFs from HTML
gem 'wicked_pdf', '~> 2.8.0'
# use [wkhtmltopdf-binary] for PDF generation dependencies
gem 'wkhtmltopdf-binary', '~> 0.12.6.7'
# use [htmltoword] for converting HTML to Word documents
gem 'htmltoword', '~> 1.1.1'
# Use [vonage] for Whatsapp API
gem 'vonage', '~> 7.16.1'
# Use [people] for contact name & last_name parsing
gem 'people', '~> 0.2.1'
# convert image to string
gem 'rtesseract', '~> 3.1.3'

group :development, :test do
  # use rspec for unit and integration tests
  gem 'factory_bot_rails', '~> 6.2.0'
  # use faker to generate model factories
  gem 'faker', '~> 2.22'
  gem 'rspec-rails', '~> 5.0', '>= 5.0.2'
  # use simplecov for coverage report
  gem 'simplecov', require: false
  # use [parallel_tests] for running tests in parallel
  gem 'parallel_tests', '~> 4.2.1'
end

group :test do
  # use shoulda-matchers to enforce unit test within models
  gem 'shoulda-matchers', '~> 5.1'
  # use pundit-matchers to enforce unit test within policies
  gem 'pundit-matchers', '~> 1.7'
  # use database_cleaner to truncate the contents of the database in every
  # example run
  # Failure/Error: require 'database_cleaner'
  # gem 'database_cleaner-active_record', '~> 2.0', '>= 2.0.1'
  gem 'database_cleaner-active_record', '~> 2.0.1'
  # enable mocks within context examples
  gem 'webmock', '~> 3.16.2'
  # use `timecop` for "time travel" and "time freezing" capabilities
  gem 'timecop', '~> 0.9.5'
  # use VCR for remote API interactions
  gem 'vcr', '~> 6.1.0'
end

group :development, :stage, :test do
  # lint
  gem 'rubocop-rails', '~> 2.15.2'
  gem 'rubocop-rspec', '~> 2.12.1'
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
end
