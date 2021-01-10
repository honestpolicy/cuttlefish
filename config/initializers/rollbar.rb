Rollbar.configure do |config|
  config.access_token = ENV["ROLLBAR_TOKEN"]

  config.enabled = %w[production staging].include?(Rails.env)

  # By default, Rollbar will try to call the `current_user` controller method
  # to fetch the logged-in user object, and then call that object's `id`
  # method to fetch this property. To customize:
  # config.person_method = 'current_or_guest_user'
  # config.person_id_method = "my_id"

  # Additionally, you may specify the following:
  # config.person_username_method = "username"
  # config.person_email_method = "email"

  # Enable delayed reporting (using Sidekiq)
  config.use_sidekiq "queue" => "rollbar"
  # If you run your staging application instance in production environment then
  # you'll want to override the environment reported by `Rails.env` with an
  # environment variable like this: `ROLLBAR_ENV=staging`. This is a recommended
  # setup for Heroku. See:
  # https://devcenter.heroku.com/articles/deploying-to-a-custom-rails-environment
  config.environment = ENV["ROLLBAR_ENV"].presence || Rails.env
end
