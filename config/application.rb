require File.expand_path('../boot', __FILE__)

require 'rails/all'

CONFIG = YAML.load(File.read(File.expand_path('../config.yml', __FILE__)))[Rails.env]

REDIS_CONFIG = CONFIG['redis']

REDIS_CACHE = "redis://#{REDIS_CONFIG['host']}:#{REDIS_CONFIG['port']}/#{REDIS_CONFIG['db']}"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WeixinDev
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, 'zh-CN']
    # Wait for fix https://github.com/rails/rails/issues/13164
    I18n.config.enforce_available_locales = false

    config.generators do |g|
      g.assets false
      g.helper false
    end

    # config.cache_store = :redis_store, "#{REDIS_CACHE}/cache_store", {expires_in: 90.minutes }

    # config.action_dispatch.rack_cache = {
    #   metastore:   "#{REDIS_CACHE}/metastore",
    #   entitystore: "#{REDIS_CACHE}/entitystore"
    # }

    # config.identity_cache_store = :redis_store, "#{REDIS_CACHE}/identity_cache_store"

    config.active_record.schema_format = :sql
  end
end
require "admin_constraint"

