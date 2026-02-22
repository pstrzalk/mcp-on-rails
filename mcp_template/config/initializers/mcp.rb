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
