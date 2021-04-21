require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module IrinaSweetshopOnRails
  class Application < Rails::Application
    config.generators do |generate|
          generate.assets false
          generate.helper false
          generate.test_framework  :test_unit, fixture: false
        end

    config.action_view.embed_authenticity_token_in_remote_forms = true #works even if JS is blocked
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.action_mailer.delivery_method = :letter_opener
    config.exceptions_app = self.routes #configuring 404 route
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
