# MCP on Rails + OAuth

A Rails application template that integrates the [Model Context Protocol (MCP)](https://github.com/anthropics/model-context-protocol) with Ruby on Rails, secured by OAuth 2.0 using [Devise](https://github.com/heartcombo/devise) and [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper).

This builds on the base [mcp-on-rails](https://github.com/pstrzalk/mcp-on-rails) template, adding full OAuth 2.0 protection with PKCE, dynamic client registration, and resource indicator support — everything needed for MCP's OAuth authorization flow.

## Quick Start

```bash
git clone https://github.com/pstrzalk/mcp-on-rails.git
rails new myapp -m mcp-on-rails-oauth/mcp
cd myapp
rails db:migrate
rails server
```

Your app now has an OAuth-protected MCP server at `/mcp`.

## What the Template Does

When you run `rails new myapp -m mcp-on-rails-oauth/mcp`, the template executes the following steps in order:

### 1. Install gems

```
bundle add mcp devise doorkeeper
```

### 2. Copy static files

Copies the contents of `mcp_template/` into the new app. This includes:

| File | Purpose |
|------|---------|
| `config/initializers/doorkeeper.rb` | Pre-configured Doorkeeper: ActiveRecord ORM, PKCE enforcement (`force_pkce`), default + optional scopes (`public`, `read`, `write`), Devise-based resource owner authentication, RFC 8707 `custom_access_token_attributes [:resource]` |
| `config/initializers/mcp.rb` | MCP configuration: `EmptyProperty` sentinel, tool autoloading from `app/tools/` |
| `app/controllers/oauth_client_registration_controller.rb` | RFC 7591 dynamic client registration — rate-limited (10/hour), validates JSON content-type, creates Doorkeeper applications, returns client credentials |
| `app/controllers/oauth_authorization_server_metadata_controller.rb` | RFC 9728 protected resource metadata + RFC 8414 authorization server metadata — returns PKCE support, endpoints, scopes, registration URL |
| `app/models/oauth_application.rb` | ActiveRecord model for `oauth_applications` table |
| `app/models/oauth_access_token.rb` | ActiveRecord model for `oauth_access_tokens` table |
| `app/models/oauth_access_grant.rb` | ActiveRecord model for `oauth_access_grants` table |
| `lib/generators/rails/mcp_generator.rb` | MCP tool generator invoked by scaffold hook |
| `lib/generators/rails/scaffold_controller_generator.rb` | Extends scaffold to trigger MCP tool generation |
| `lib/generators/rails/templates/*.rb.tt` | Templates for show/index/create/update/delete tools |
| `lib/generators/mcp_tool/` | Standalone custom tool generator |
| `lib/tasks/mcp.rake` | `rake mcp:tools` task to list registered tools |

### 3. Run Devise generators

```ruby
generate "devise:install"    # Creates devise.rb initializer + locale
generate "devise", "User"    # Creates User model + migration, inserts devise_for :users into routes
generate "devise:views"      # Creates customizable view templates for sign-in/sign-up
```

### 4. Add Doorkeeper associations to User model

Injects `has_many :access_grants` and `has_many :access_tokens` into the User model so users are linked to their OAuth tokens.

### 5. Generate Doorkeeper migration and enable foreign keys

```ruby
generate "doorkeeper:migration"
```

Then uncomments the foreign key lines in the generated migration to reference the `users` table. The template skips `doorkeeper:install` because it ships its own pre-configured `doorkeeper.rb` initializer.

### 6. Create PKCE migration

Adds `code_challenge` and `code_challenge_method` columns to `oauth_access_grants` — required for PKCE (Proof Key for Code Exchange).

### 7. Create resource indicator migration (RFC 8707)

Adds a `resource` column to **both** `oauth_access_grants` and `oauth_access_tokens`. Doorkeeper's `custom_access_token_attributes` stores attributes on both tables.

### 8. Create OAuth-protected MCP controller

Creates `McpController` inheriting from `ActionController::API` (not `ApplicationController` — avoids CSRF issues) with:
- `doorkeeper_authorize! :public, :read, :write` — requires a valid OAuth token
- Token audience validation (RFC 8707) — ensures the token's `resource` claim matches the MCP endpoint
- `server_context` passing the token and `user_id` to MCP tools

### 9. Inject routes

Adds all OAuth and MCP routes after the Devise-generated `devise_for :users` line:
- `use_doorkeeper` — standard Doorkeeper OAuth routes
- `POST /oauth/register` — dynamic client registration
- `GET /.well-known/oauth-protected-resource` — protected resource metadata
- `GET /.well-known/oauth-authorization-server` — authorization server metadata
- `POST /mcp` + `GET /mcp` — MCP endpoint

### 10. Extend ApplicationRecord

Adds `to_mcp_response` method for consistent MCP text formatting of model attributes.

### 11. Configure autoloading

Updates `config/application.rb` to exclude generators from autoloading and allow all hosts (useful for development with ngrok, tunnels, etc.).

## OAuth Flow

The full authorization flow follows MCP's OAuth specification:

1. **Discovery** — Client fetches `GET /.well-known/oauth-protected-resource` to find the authorization server
2. **Server metadata** — Client fetches `GET /.well-known/oauth-authorization-server` for endpoints and capabilities
3. **Client registration** — `POST /oauth/register` with client metadata (RFC 7591)
4. **Authorization** — `GET /oauth/authorize` with PKCE `code_challenge` (S256) and `resource` parameter
5. **User authentication** — Devise handles sign-in/sign-up
6. **Token exchange** — `POST /oauth/token` with `code_verifier` and `resource` parameter
7. **MCP requests** — `POST /mcp` with `Authorization: Bearer <token>`

## Usage

### Scaffolding models with MCP tools

```bash
rails generate scaffold Post title:string content:text
rails db:migrate
```

This creates standard Rails files plus 5 MCP tools in `app/tools/posts/`:
- `show_tool.rb` — Retrieve a single post by ID
- `index_tool.rb` — List posts with pagination
- `create_tool.rb` — Create new posts
- `update_tool.rb` — Update existing posts
- `delete_tool.rb` — Delete posts

### Creating custom MCP tools

```bash
rails generate mcp_tool WeatherCheck location:string
```

### Listing available tools

```bash
rake mcp:tools
```

## Supported RFCs

| RFC | Description | Endpoint |
|-----|-------------|----------|
| OAuth 2.0 + PKCE | Authorization with Proof Key for Code Exchange (S256) | `/oauth/authorize`, `/oauth/token` |
| RFC 7591 | Dynamic Client Registration | `POST /oauth/register` |
| RFC 8414 | Authorization Server Metadata | `GET /.well-known/oauth-authorization-server` |
| RFC 8707 | Resource Indicators | `resource` parameter in auth + token requests |
| RFC 9728 | Protected Resource Metadata | `GET /.well-known/oauth-protected-resource` |

## Project Structure

After applying the template:

```
app/
├── controllers/
│   ├── mcp_controller.rb                              # OAuth-protected MCP endpoint
│   ├── oauth_client_registration_controller.rb        # RFC 7591
│   └── oauth_authorization_server_metadata_controller.rb  # RFC 8414 + 9728
├── models/
│   ├── user.rb                                        # Devise user with OAuth associations
│   ├── oauth_application.rb
│   ├── oauth_access_token.rb
│   └── oauth_access_grant.rb
├── tools/                                             # MCP tools (auto-generated per scaffold)
│   └── posts/
│       ├── show_tool.rb
│       ├── index_tool.rb
│       ├── create_tool.rb
│       ├── update_tool.rb
│       └── delete_tool.rb
└── views/
    └── devise/                                        # Customizable auth views

config/
├── initializers/
│   ├── doorkeeper.rb                                  # OAuth + PKCE config
│   ├── devise.rb                                      # User auth config
│   └── mcp.rb                                         # MCP tool autoloading
└── routes.rb                                          # All OAuth + MCP routes

db/migrate/
├── *_devise_create_users.rb
├── *_create_doorkeeper_tables.rb
├── *_enable_pkce.rb
└── *_add_resource_to_oauth_tables.rb
```

## Connecting AI Assistants

Configure your MCP client to connect using OAuth:

```json
{
  "name": "my-rails-app",
  "type": "StreamableHttp",
  "url": "http://localhost:3000/mcp"
}
```

The client must complete the OAuth PKCE flow before making MCP requests — the `/mcp` endpoint returns 401 without a valid Bearer token.

## License

MIT License
