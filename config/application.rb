require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module VoicegenRailsApi
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true

    # Disable host authorization for Railway (API-only app)
    config.middleware.delete ActionDispatch::HostAuthorization
  end
end