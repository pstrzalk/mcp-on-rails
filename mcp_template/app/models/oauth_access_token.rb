# Doorkeeper access token model — maps to the oauth_access_tokens table created
# by Doorkeeper's migration. Includes the custom `resource` column for RFC 8707
# resource indicator support.
class OauthAccessToken < ApplicationRecord
end
