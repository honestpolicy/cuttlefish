FROM ruby:2.7.2-slim-buster

ENV BUNDLER_VERSION=2.2.4 NODE_ENV=production RAILS_ENV=production RAILS_SERVE_STATIC_FILES=true RAILS_LOG_TO_STDOUT=true PORT=3000

RUN apt-get update -qq && apt-get install -y curl build-essential git libpq-dev && \
  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get update && apt-get install -y nodejs && \
  apt-get clean

RUN gem install bundler:2.2.4 foreman --no-document && \
  gem cleanup

RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true'
RUN bundle config set --local without 'development test'
RUN bundle install
COPY . .

EXPOSE 3000 2222
CMD ["/bin/sh", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]

