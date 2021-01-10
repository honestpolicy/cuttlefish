require 'sidekiq/web'
Sidekiq::Web.set :sessions, false

REDIS_OPTIONS = { url: ENV["REDIS_URL"],
                  network_timeout: 5,
                  pool_timeout: 5,
                  reconnect_attempts: 3,
                  size: 22 }

Sidekiq.configure_server do |config|
  config.redis = REDIS_OPTIONS
end

Sidekiq.configure_client do |config|
  config.redis = if Rails.env.development?
                   { url: Rails.application.credentials[:redis_url] }
                 else
                   { url: Rails.application.credentials[:redis_url],
                     password: Rails.application.credentials[:redis_password],
                     network_timeout: 5,
                     pool_timeout: 5,
                     reconnect_attempts: 3,
                     size: 22 }
                 end
end
