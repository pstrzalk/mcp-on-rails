# MCP on Rails

A Rails application template that seamlessly integrates the [Model Context Protocol (MCP)](https://github.com/anthropics/model-context-protocol) with Ruby on Rails applications using the [mcp](https://rubygems.org/gems/mcp) gem.

## What This Does

This template bootstraps a new Rails application with MCP server capabilities, allowing AI assistants to interact with your Rails models through structured tools. When you scaffold new models, MCP tools are automatically generated alongside the standard Rails files.

You may read a longer introduction to the topic in my article at https://www.visuality.pl/posts/mcp-template-for-rails-applications

## Quick Start

Create a new Rails application with MCP integration:

```bash
git clone https://github.com/pstrzalk/mcp-on-rails.git
rails new myapp -m mcp-on-rails/mcp
cd myapp
```

That's it! Your Rails app now has:
- MCP server endpoint at `/mcp`
- Automatic MCP tool generation during scaffolding
- All necessary MCP infrastructure configured

### Adding the MCP template to an existing Rails application

You may just as easily apply this template to an existing Rails app.
```bash
git clone https://github.com/pstrzalk/mcp-on-rails.git
cd your-project/
rails app:template LOCATION=../mcp-on-rails/mcp
```

## Usage

### 1. Scaffolding Models with MCP Tools

When you generate a scaffold, MCP tools are automatically created:

```bash
rails generate scaffold Post title:string content:text author:string
```

This creates the standard Rails files PLUS MCP tools in `app/tools/posts/`:
- `show_tool.rb` - Retrieve a single post by ID
- `index_tool.rb` - List posts with filtering and pagination
- `create_tool.rb` - Create new posts
- `update_tool.rb` - Update existing posts
- `delete_tool.rb` - Delete posts

### 2. Creating Custom MCP Tools

Generate standalone MCP tools for custom functionality:

```bash
rails generate mcp_tool WeatherCheckTool location:string
```

This creates `app/tools/weather_tool.rb` with a customizable MCP tool structure. When you specify attributes, the generator automatically creates the input schema with proper types and includes them as method parameters.

### 3. Starting Your MCP Server

```bash
rails server
```

Your MCP server is now available at:
- **HTTP**: `http://localhost:3000/mcp` (streamable HTTP transport)
- **Development**: Connect AI assistants to this endpoint

The server uses streamable HTTP transport, allowing for real-time communication between AI assistants and your Rails application.

### 4. Viewing Available Tools

List all registered MCP tools:

```bash
rake mcp:tools
```

## Example: Generated MCP Tools

For a `Post` model with `title:string` and `content:text`, the generated `create_tool.rb` looks like:

```ruby
module Posts
  class CreateTool < MCP::Tool
    tool_name "post-create-tool"
    description "Create a new Post entity"

    input_schema(
      properties: {
        title: { type: "string" },
        content: { type: "string" },
      },
      required: []
    )

    def self.call(title: nil, content: nil, server_context:)
      post = Post.new(title: title, content: content)

      if post.save
        MCP::Tool::Response.new([{
          type: "text",
          text: "Created #{post.to_mcp_response}"
        }])
      else
        MCP::Tool::Response.new([{
          type: "text",
          text: "Post was not created due to errors: #{post.errors.full_messages.join(', ')}"
        }])
      end
    rescue StandardError => e
      MCP::Tool::Response.new([{
        type: "text",
        text: "An error occurred: #{e.message}"
      }])
    end
  end
end
```

## MCP Tool Features

### Automatic Schema Generation
- **String/Text fields**: Mapped to `type: "string"`
- **Integer/Reference fields**: Mapped to `type: "integer"`
- **Boolean fields**: Mapped to `type: "boolean"`
- **References**: Automatically included in required fields and filtering

### Built-in Functionality
- **CRUD Operations**: Full create, read, update, delete support
- **Filtering**: Index tools support filtering by reference fields
- **Pagination**: Index tools include count parameter (default: 10)
- **Error Handling**: Comprehensive error responses
- **Validation**: Rails model validations are respected

### Model Integration
Each model gets a `to_mcp_response` method for consistent formatting:

```ruby
def to_mcp_response
  result = [self.class.name]
  result += attributes.map { |key, value| "  **#{key}**: #{value}" }
  result.join("\n")
end
```

## Project Structure

After using this template, your Rails app will have:

```
app/
├── controllers/
│   └── mcp_controller.rb          # MCP protocol handler
├── models/
│   └── application_record.rb      # Extended with to_mcp_response
└── tools/                         # MCP tools directory
    └── posts/                     # Auto-generated for each model
        ├── show_tool.rb
        ├── index_tool.rb
        ├── create_tool.rb
        ├── update_tool.rb
        └── delete_tool.rb

config/
├── routes.rb                      # MCP endpoint routes
└── initializers/
    └── mcp.rb                     # MCP configuration

lib/
└── generators/
    ├── mcp_tool/
    │   ├── ...
    │   └── mcp_tool_generator.rb  # Custom tool generator
    └── rails/
        ├── ...
        ├── mcp_generator.rb       # Scaffold hook generator
        └── scaffold_controller_generator.rb  # Extended for MCP
```

## Connecting AI Assistants

Configure your AI assistant to connect to your Rails MCP server:

```json
{
  "name": "my-app",
  "type": "StreamableHttp",
  "url": "http://localhost:3000/mcp"
}
```

## Development Commands

```bash
# Start the Rails server
rails server

# Generate models with MCP tools
rails generate scaffold ModelName field:type otherField:otherType

# Generate custom MCP tools
rails generate mcp_tool ToolName field:type otherField:otherType

# List all MCP tools
rake mcp:tools
```

## How It Works

This template uses Rails' generator hook system to extend the standard scaffold controller generator. When you run `rails generate scaffold`, it automatically invokes the MCP generator to create tools alongside the standard Rails files.

The approach:
- Only adds MCP-specific code, doesn't override Rails generators
- Works with Rails updates automatically
- Uses Rails' intended extension mechanism (like jbuilder)

## Contributing

This is a Rails application template. To modify:

1. Edit `mcp` - the main template file
2. Update `mcp_template/` - files copied to new Rails apps
3. Test with: `rails new testapp -m mcp`

## License

MIT License - see the template code for details.
