# frozen_string_literal: true

require "rails/generators/resource_helpers"

module Rails
  module Generators
    class McpGenerator < NamedBase
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      TOOLS = {
        "show_tool"   => "Show",
        "index_tool"  => "Index",
        "create_tool" => "Create",
        "update_tool" => "Update",
        "delete_tool" => "Delete"
      }.freeze

      def create_mcp_tools
        choice = ask("Generate MCP tools? (All / Some / None)", limited_to: %w[all some none a s n], case_insensitive: true)

        case choice.downcase[0]
        when "n"
          say "Skipping MCP tool generation", :yellow
          return
        when "a"
          TOOLS.each_key { |tool| create_tool_file(tool) }
        when "s"
          TOOLS.each do |tool, label|
            if yes?("  Generate #{label} tool for #{class_name}? (y/n)")
              create_tool_file(tool)
            else
              say_status :skip, File.join("app", "tools", controller_file_path, "#{tool}.rb"), :yellow
            end
          end
        end
      end

      private

      def create_tool_file(tool)
        template "#{tool}.rb", File.join("app", "tools", controller_file_path, "#{tool}.rb")
      end

      def map_attribute_type(type)
        case type.to_sym
        when :references, :belongs_to, :timestamp, :integer
          :integer
        when :boolean
          :boolean
        else
          :string
        end
      end
    end
  end
end
