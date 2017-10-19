# frozen_string_literal: true

namespace :g5_authenticatable do
  desc 'Purge local user data from the DB'
  task :purge_users do
    G5Authenticatable::User.destroy_all
  end
end
