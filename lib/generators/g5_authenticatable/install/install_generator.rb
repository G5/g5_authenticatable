class G5Authenticatable::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  # Required for Rails::Generators::Migrations
  def self.next_migration_number(dirname)
    next_migration_number = current_migration_number(dirname) + 1
    ActiveRecord::Migration.next_migration_number(next_migration_number)
  end

  def mount_engine
    route "mount G5Authenticatable::Engine => '/g5_auth'"
  end

  def create_initializer
    template 'initializer.rb', 'config/initializers/g5_authenticatable.rb'
  end

  def create_users_migration
    copy_migration('create_g5_authenticatable_users')
  end

  def users_contact_info_migration
    copy_migration('add_g5_authenticatable_users_contact_info')
  end

  def create_roles_migration
    copy_migration('create_g5_authenticatable_roles')
  end

  private
  def copy_migration(name)
    migration_template "migrate/#{name}.rb", "db/migrate/#{name}.rb"
  end
end
