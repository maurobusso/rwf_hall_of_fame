ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "spec_helper"

# Ensure the test database schema is loaded
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue NoMethodError, NameError
  # Fall back to loading the schema if the helper isn't available (older/newer Rails)
  load Rails.root.join("db/schema.rb") if File.exist?(Rails.root.join("db/schema.rb"))
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
