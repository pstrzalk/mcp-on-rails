# frozen_string_literal: true

require "rails/generators/resource_helpers"

module Rails
  module Generators
    class McpGenerator < NamedBase
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def create_mcp_tools
        template "show_tool.rb",   File.join("app", "tools", controller_file_path, "show_tool.rb")
        template "index_tool.rb",  File.join("app", "tools", controller_file_path, "index_tool.rb")
        template "create_tool.rb", File.join("app", "tools", controller_file_path, "create_tool.rb")
        template "update_tool.rb", File.join("app", "tools", controller_file_path, "update_tool.rb")
        template "delete_tool.rb", File.join("app", "tools", controller_file_path, "delete_tool.rb")
      end

      private

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