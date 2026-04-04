# Sentinel value used in update tools to distinguish between a parameter that was
# sent with an empty/nil value vs a parameter that was not sent at all.
# This enables PATCH semantics (update only provided fields) instead of PUT semantics
# (replace all fields), which is the default update behavior in Rails.
# See: app/tools/**/update_tool.rb
MCP::EmptyProperty = Class.new

# Require all tools and prompts to be able to list descendants
Rails.application.config.to_prepare do
  Dir[Rails.root.join("app/tools/**/*.rb")].each do |file|
    require_dependency file
  end

  Dir[Rails.root.join("app/prompts/**/*.rb")].each do |file|
    require_dependency file
  end
end
