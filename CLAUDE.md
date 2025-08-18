# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Description

This is an **MCP on Rails template** - a Rails application template that seamlessly integrates the [Model Context Protocol (MCP)](https://github.com/anthropics/model-context-protocol) with Ruby on Rails applications using the [`mcp` gem](https://rubygems.org/gems/mcp).

The project consists of two main components:
1. **`mcp`** - The Rails application template file
2. **`mcp_template/`** - Directory containing template files copied to new Rails applications

The `mcp` template bootstraps a new Rails app with MCP server capabilities. When run with `rails new myapp -m mcp`, it:

1. Adds the `mcp` gem to the Gemfile
2. Copies template files from `mcp_template/` directory
3. Creates an `McpController` that handles MCP protocol requests at `/mcp` endpoint (streamable HTTP transport)
4. Sets up Rails generator hooks for automatic MCP tool generation during scaffolding
5. Adds a `to_mcp_response` method to ActiveRecord models for consistent MCP formatting
6. Configures Rails to ignore generators from autoloading

When you scaffold new models (`rails generate scaffold Post title:string`), MCP tools are automatically generated alongside standard Rails files, providing AI assistants with structured access to CRUD operations.

## How Rails generators work:
Read contents of https://raw.githubusercontent.com/rails/rails/refs/heads/main/guides/source/generators.md to get context about Rails generators.

## MCP Tools Architecture

MCP Tools are Ruby classes that inherit from `MCP::Tool` and provide AI assistants with structured access to application functionality:

- **Location**: `app/tools/` directory
- **Structure**: Each tool defines `tool_name`, `description`, `input_schema`, and `call` method
- **Autoloading**: Tools are automatically loaded via `config/initializers/mcp.rb`
- **Generation**: Use `rails generate mcp_tool ToolName field:type` to create new tools
- **Response Format**: Tools return `MCP::Tool::Response` objects with text content
- **Auto-generation**: Scaffold generates 5 CRUD tools per model (show, index, create, update, delete)

### Generated Tool Types

For each scaffolded model, these tools are automatically created:
- **Show Tool**: Retrieve single record by ID
- **Index Tool**: List records with filtering by references and pagination (count parameter, default: 10)
- **Create Tool**: Create new records with validation
- **Update Tool**: Update existing records with validation
- **Delete Tool**: Delete records by ID

### Tool Structure Example:
```ruby
module Posts
  class CreateTool < MCP::Tool
    tool_name "post-create-tool"
    description "Create a new Post entity"
    
    input_schema(
      properties: {
        title: { type: "string" },
        content: { type: "string" }
      },
      required: []
    )

    def self.call(title: nil, content: nil, server_context:)
      post = Post.new(title: title, content: content)
      
      if post.save
        MCP::Tool::Response.new([{ type: "text", text: "Created #{post.to_mcp_response}" }])
      else
        MCP::Tool::Response.new([{ type: "text", text: "Post was not created due to errors: #{post.errors.full_messages.join(', ')}" }])
      end
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "An error occurred: #{e.message}" }])
    end
  end
end
```

### Type Mapping
- **String/Text fields**: `type: "string"`
- **Integer/Reference fields**: `type: "integer"`
- **Boolean fields**: `type: "boolean"`
- **References**: Automatically included in filtering and as required fields

## Template Architecture

The template uses Rails' generator hook system to extend the standard scaffold controller generator. This approach is:
- **Lightweight**: Only adds MCP-specific code, doesn't override Rails generators
- **Maintainable**: Works with Rails updates automatically  
- **Standards-compliant**: Uses Rails' intended extension mechanism (like jbuilder)

When you run `rails generate scaffold`, it automatically invokes the MCP generator to create tools alongside the standard Rails files.

## Development Commands

### Template Usage
```bash
# Create new Rails app with MCP integration
rails new myapp -m mcp
cd myapp
```

### Scaffolding with MCP Tools
```bash
# Generate model with automatic MCP tools
rails generate scaffold Post title:string content:text author:string

# This creates standard Rails files PLUS MCP tools:
# - app/tools/posts/show_tool.rb
# - app/tools/posts/index_tool.rb  
# - app/tools/posts/create_tool.rb
# - app/tools/posts/update_tool.rb
# - app/tools/posts/delete_tool.rb
```

### Custom MCP Tools
```bash
# Basic tool with no parameters
rails generate mcp_tool Weather

# Tool with typed parameters (like ActiveRecord attributes)
rails generate mcp_tool WeatherCheck location:string temperature:integer

# Complex tool with multiple parameter types
rails generate mcp_tool EmailSender recipient:string subject:string body:text urgent:boolean
```

### MCP-Specific Commands
```bash
rake mcp:tools          # List all registered MCP tools
rails server            # Start MCP server (streamable HTTP at /mcp)
rails test              # Run test suite
rails db:migrate        # Run database migrations
rails db:seed           # Seed database
```

## Code Organization

This repository contains:
- **`mcp`** - Main Rails application template file
- **`mcp_template/`** - Template files copied to new Rails applications
  - `lib/generators/rails/mcp_generator.rb` - MCP tool generator (invoked by scaffold hook)
  - `lib/generators/rails/scaffold_controller_generator.rb` - Scaffold extension with MCP hook
  - `lib/generators/rails/templates/` - MCP tool templates
  - `lib/generators/mcp_tool/` - Standalone MCP tool generator

After using the template, Rails apps will have:
- `app/controllers/mcp_controller.rb` - MCP protocol endpoint handler (streamable HTTP)
- `app/tools/` - MCP tool implementations (auto-generated during scaffolding)
- `config/initializers/mcp.rb` - MCP configuration and tool autoloading
- `app/models/application_record.rb` - Extended with `to_mcp_response` method
