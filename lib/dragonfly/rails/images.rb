require 'dragonfly'
require 'rack/cache'

### The dragonfly app ###

app = Dragonfly::App[:images]
app.configure_with(Dragonfly::Config::RailsImages)

### Extend active record ###
ActiveRecord::Base.extend Dragonfly::ActiveRecordExtensions
ActiveRecord::Base.register_dragonfly_app(:image, app)

### Insert the middleware ###
# Where the middleware is depends on the version of Rails
middleware = Rails.respond_to?(:application) ? Rails.application.middleware : ActionController::Dispatcher.middleware
middleware.insert_after Rack::Lock, Dragonfly::Middleware, :images
middleware.insert_before Dragonfly::Middleware, Rack::Cache, {
  :verbose     => true,
  :metastore   => "file:#{Rails.root}/tmp/dragonfly/cache/meta",
  :entitystore => "file:#{Rails.root}/tmp/dragonfly/cache/body"
}