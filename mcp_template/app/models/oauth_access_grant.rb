# Doorkeeper access grant model — maps to the oauth_access_grants table created
# by Doorkeeper's migration. Provides an ApplicationRecord-based model so the
# table participates in standard Rails conventions (e.g. foreign key references).
class OauthAccessGrant < ApplicationRecord
end
