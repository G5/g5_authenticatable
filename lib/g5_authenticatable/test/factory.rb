# frozen_string_literal: true

# TODO: drop factory_girl support and force people to upgrade
# once g5_updatable factories are using the FactoryBot constant
begin
  # We need to define the aliased constant before the *_rails gem
  # tries to load any factory definitions
  require 'factory_bot'
  FactoryGirl = FactoryBot
  require 'factory_bot_rails'
rescue LoadError
  require 'factory_girl'
  FactoryBot = FactoryGirl
  require 'factory_girl_rails'
end

require 'g5_authenticatable/test/factories/roles'
require 'g5_authenticatable/test/factories/global_users'
require 'g5_authenticatable/test/factories/client_users'
require 'g5_authenticatable/test/factories/location_users'
