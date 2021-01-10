# frozen_string_literal: true

unless defined?(APP_VERSION)
  APP_VERSION = if Rails.env.production?
                  '1'
                  # File.read(File.join(Rails.root, "REVISION"))[0..6] || '1'
                else
                  `git describe --always`
                end
end
