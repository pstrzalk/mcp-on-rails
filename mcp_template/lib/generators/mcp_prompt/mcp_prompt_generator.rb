# frozen_string_literal: true

class McpPromptGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  argument :prompt_arguments, type: :array, default: [], banner: "arg arg:required"

  def create_prompt_file
    template "prompt.rb.tt", File.join("app", "prompts", "#{file_name}.rb")
  end

  private

  def prompt_class_name
    file_name.classify
  end

  def prompt_identifier
    file_name.tr("_", "-").sub(/-prompt\z/, "")
  end

  def parsed_arguments
    prompt_arguments.map do |arg|
      parts = arg.split(":")
      { name: parts[0], required: parts[1] == "required" }
    end
  end
end
