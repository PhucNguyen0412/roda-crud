dev = ENV['RACK_ENV'] == 'development'

if dev
  require 'logger'
  logger = Logger.new($stdout)
end

require 'rack/unreloader'
Unreloader = Rack::Unreloader.new(subclasses: %w'Roda Sequel::Model', logger: logger, reload: dev){MyApp}
require_relative 'models'
Unreloader.require('app.rb'){'MyApp'}
run(dev ? Unreloader : MyApp.freeze.app)

unless dev
  begin
    require 'refrigerator'
  rescue LoadError
  else
    require 'tilt/sass' unless File.exist?(File.expand_path('../compiled_assets.json', __FILE__))
    Refrigerator.freeze_core
  end
end

# Roda.route { "Hello world!" }
# run Roda.app
