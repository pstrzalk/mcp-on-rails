# frozen_string_literal: true

namespace :mcp do
  desc "List MCP Tools"
  task tools: :environment do
    tools = MCP::Tool.descendants.sort_by(&:name)
    max_name = tools.map { |k| k.name.length }.max || 0

    tools.each do |klass|
      description = klass.description.to_s.split("\n").first.to_s
      puts "#{klass.name.ljust(max_name)}  #{description}"
    end
  end

  namespace :tools do
    desc "List MCP Tools with full details"
    task verbose: :environment do
      MCP::Tool.descendants.sort_by(&:name).each do |klass|
        description_split = klass.description.to_s.split("\n")
        description = description_split.first
        description += "..." if description_split.count > 1

        schema = klass.input_schema
        properties = schema.dig(:properties) || schema.dig("properties") || {}
        required = schema.dig(:required) || schema.dig("required") || []

        schema_parts = properties.map { |name, opts| "#{name}:#{opts[:type] || opts["type"]}" }
        schema_line = schema_parts.join(", ")
        schema_line += " (required: #{required.join(', ')})" if required.any?

        puts klass.name
        puts "  Description: #{description}"
        puts "  Schema: #{schema_line}"
        puts
      end
    end
  end

  desc "List MCP Prompts"
  task prompts: :environment do
    prompts = MCP::Prompt.descendants.sort_by(&:name)
    max_name = prompts.map { |k| k.name.length }.max || 0

    prompts.each do |klass|
      puts "#{klass.name.ljust(max_name)}  #{klass.description}"
    end
  end

  namespace :prompts do
    desc "List MCP Prompts with full details"
    task verbose: :environment do
      MCP::Prompt.descendants.sort_by(&:name).each do |klass|
        args = (klass.arguments || []).map { |a| "#{a.name}#{a.required ? ' (required)' : ''}" }.join(", ")
        puts "#{klass.name}\n  Description: #{klass.description}\n  Arguments: #{args}\n"
      end
    end
  end
end
