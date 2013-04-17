# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require gems we care about
require 'rubygems'

require 'uri'
require 'pathname'

require 'pg'
require 'active_record'
require 'logger'

require 'sinatra'

if development?
  require "sinatra/reloader"
  require 'debugger'
end

require 'erb'
require 'oauth'
# require 'httparty'
require 'twitter'
require 'sidekiq'
require 'redis'
require 'autoscaler'
require 'autoscaler/sidekiq'
require 'autoscaler/heroku_scaler'

require 'heroku-api'


# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

APP_NAME = APP_ROOT.basename.to_s

# Set up the controllers and helpers
Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each { |file| require file }

# Set up the database and models
require APP_ROOT.join('config', 'database')

if Sinatra::Application.development?
  twitter_data = YAML.load_file(APP_ROOT.join('config','twitter.yml'))
  ENV['CONSUMER_KEY'] = twitter_data['consumer_key']
  ENV['CONSUMER_SECRET'] = twitter_data['consumer_secret']
  heroku_data = YAML.load_file(APP_ROOT.join('config','heroku.yml'))
  ENV['HEROKU_API_KEY'] = heroku_data['heroku_api']
  ENV['HEROKU_APP'] = heroku_data['heroku_app']
end

Twitter.configure do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Autoscaler::Sidekiq::Client, 'default' => Autoscaler::HerokuScaler.new
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add(Autoscaler::Sidekiq::Server, Autoscaler::HerokuScaler.new, 60)
  end
end



