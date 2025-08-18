# frozen_string_literal: true

class McpToolGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  def create_tool_file
    template "tool.rb.tt", File.join("app", "tools", "#{file_name}.rb")
  end

  private

  def tool_class_name
    file_name.classify
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
