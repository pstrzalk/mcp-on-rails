# Load required libraries for MCP tools
require "net/http"
require "json"
require "uri"

MCP::EmptyProperty = Class.new

# Require all tools to be able to list dependencies of MCP::Tool
Rails.application.config.to_prepare do
  Dir[Rails.root.join("app/tools/**/*.rb")].each do |file|
    require_dependency file
  end
end
