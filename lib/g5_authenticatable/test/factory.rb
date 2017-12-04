# frozen_string_literal: true

# We can drop support for factory_girl once the g5_updatable factories
# are using the FactoryBot constant
begin
  require 'factory_bot_rails'
  FactoryGirl = FactoryBot # to make g5_updatable factories work
rescue LoadError
  require 'factory_girl_rails'
  FactoryBot = FactoryGirl # to make the auth factories work
end

require 'g5_authenticatable/test/factories/roles'
require 'g5_authenticatable/test/factories/global_users'
require 'g5_authenticatable/test/factories/client_users'
require 'g5_authenticatable/test/factories/location_users'
