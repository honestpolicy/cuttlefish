# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "5.2.4.4"

gem "pg"

gem "sass-rails"
# Don't upgrade to Bootstrap 3. It's already responsive, for example, so
# there's a bunch of things we need to do for the upgrade
gem "bootstrap-sass", "~> 2.0"
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem "therubyracer", platforms: :ruby

gem "less-rails"

gem "uglifier"

gem "jquery-rails"

gem "jbuilder"

gem "eventmachine"
gem "sidekiq"
gem "sinatra", require: nil

gem "batch-loader"
gem "devise"
gem "devise_invitable"
gem "dkim"
gem "dnsbl-client"
gem "factory_bot_rails"
gem "file-tail"
gem "foreman"
gem "formtastic"
# Use pull request that has needed Rails 4 improvements https://github.com/pkurek/flatui-rails/pull/25
gem "flatui-rails", git: "https://github.com/iffyuva/flatui-rails.git",
                    ref: "3d3c423"
gem "fog-aws"
gem "font-awesome-rails"
gem "friendly_id"
gem "google-analytics-rails"
gem "graphql"
gem "graphql-client"
gem "graphql-errors"
gem "graphql-guard"
gem "gravatar_image_tag"
gem "haml-rails"
gem "honeybadger"
gem "syslog_protocol"
gem "will_paginate"
# Need commit c9331088146e456a69bd6e94298c80d09be3ee74
gem "formtastic-bootstrap",
    git: "https://github.com/mjbellantoni/formtastic-bootstrap.git",
    ref: "f86eaef93bea0a06879b3977d7554864964a623f"
gem "haml-coderay"
gem "minitar"
gem "newrelic_rpm"
gem "nokogiri"
gem "premailer"
gem "pundit"
gem "user_agent_parser"
gem "virtus"

# For doing the webhooks to external sites
gem "rest-client"

gem "jwt"
gem "puma"
gem "rack-mini-profiler"
gem "rollbar"

group :development do
  gem "annotate"
  gem "faker", git: "https://github.com/stympy/faker.git", branch: "master"
  gem "graphiql-rails"
  gem "rubocop", require: false
  gem "spring"
  gem "spring-commands-rspec"

  gem "guard"
  gem "guard-rspec"
  gem "listen"
  gem "rb-fchange", require: false
  gem "rb-fsevent", require: false
  gem "rb-inotify", require: false
  gem "ruby_gntp"
  gem "terminal-notifier"
  gem "terminal-notifier-guard"
end

group :test do
  gem "climate_control"
  gem "coveralls", require: false
  gem "database_cleaner"
  gem "rails-controller-testing"
  gem "vcr"
  gem "webmock"
end

group :development, :test do
  gem "capybara"
  gem "dotenv-rails"
  gem "rmagick"
  gem "rspec-activemodel-mocks"
  gem "rspec-rails"
  gem "selenium-webdriver"
end

gem "redis-session-store"
