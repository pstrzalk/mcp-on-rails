# Doorkeeper application model — maps to the oauth_applications table created
# by Doorkeeper's migration. Applications are registered via dynamic client
# registration (RFC 7591) at POST /oauth/register.
class OauthApplication < ApplicationRecord
end
