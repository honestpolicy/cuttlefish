# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :redis_session_store, {
  key: "_cuttlefish_session",
  redis: {
    expire_after: 1.week,       # cookie expiration
    ttl: 120.minutes,           # Redis expiration, defaults to 'expire_after'
    url: ENV["REDIS_URL"]
  }
}
