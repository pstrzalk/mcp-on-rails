# frozen_string_literal: true

namespace :mcp do
  desc "List MCP Tools"
  task tools: :environment do
    puts "Listing registered MCP tools:"

    MCP::Tool.descendants.each do |klass|
      description_split = klass.description.to_s.split("\n")
      description = description_split.first
      description += "..." if description_split.count > 1

      puts "#{klass.name}\n  Description: #{description}\n  Input Schema: #{klass.input_schema.to_json}\n\n"
    end
  end
end
