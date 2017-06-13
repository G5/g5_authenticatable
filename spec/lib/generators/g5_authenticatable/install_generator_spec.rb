# frozen_string_literal: true

require 'spec_helper'

# For some reason, trying to load the generator from this spec
# causes problems without an explicit require statement, even
# though the rails executable is able to find the generator
# when you execute it from the command line
require 'generators/g5_authenticatable/install/install_generator'

describe G5Authenticatable::InstallGenerator, type: :generator do
  destination File.expand_path('../../../../tmp', __FILE__)

  before do
    prepare_destination
    setup_routes
    setup_application_controller
    run_generator
  end

  context 'under rails 4.x', skip: !Rails.version.starts_with?('4') do
    it 'should copy the unversioned create user migration' do
      expect(destination_root).to have_structure {
        directory 'db' do
          directory 'migrate' do
            migration 'create_g5_authenticatable_users' do
              contains "class CreateG5AuthenticatableUsers < ActiveRecord::Migration\n"
            end
          end
        end
      }
    end

    it 'should copy the unversioned migration to add user contact info' do
      expect(destination_root).to have_structure {
        directory 'db' do
          directory 'migrate' do
            migration 'add_g5_authenticatable_users_contact_info' do
              contains "class AddG5AuthenticatableUsersContactInfo < ActiveRecord::Migration\n"
            end
          end
        end
      }
    end

    it 'should copy the unversioned migration to add user roles' do
      expect(destination_root).to have_structure {
        directory 'db' do
          directory 'migrate' do
            migration 'create_g5_authenticatable_roles' do
              contains "class CreateG5AuthenticatableRoles < ActiveRecord::Migration\n"
            end
          end
        end
      }
    end
  end

  context 'under rails 5.x', skip: !Rails.version.starts_with?('5') do
    it 'should copy the versioned create user migration' do
      expect(destination_root).to have_structure {
        directory 'db' do
          directory 'migrate' do
            migration 'create_g5_authenticatable_users' do
              migration_version = "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
              contains "class CreateG5AuthenticatableUsers < ActiveRecord::Migration#{migration_version}\n"
            end
          end
        end
      }
    end

    it 'should copy the unversioned migration to add user contact info' do
      expect(destination_root).to have_structure {
        directory 'db' do
          directory 'migrate' do
            migration 'add_g5_authenticatable_users_contact_info' do
              migration_version = "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
              contains "class AddG5AuthenticatableUsersContactInfo < ActiveRecord::Migration#{migration_version}\n"
            end
          end
        end
      }
    end

    it 'should copy the unversioned migration to add user roles' do
      expect(destination_root).to have_structure {
        directory 'db' do
          directory 'migrate' do
            migration 'create_g5_authenticatable_roles' do
              migration_version = "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
              contains "class CreateG5AuthenticatableRoles < ActiveRecord::Migration#{migration_version}\n"
            end
          end
        end
      }
    end
  end

  it 'should copy the initializer' do
    expect(destination_root).to have_structure {
      directory 'config' do
        directory 'initializers' do
          file 'g5_authenticatable.rb' do
            contains '# G5Authenticatable.strict_token_validation = true'
          end
        end
      end
    }
  end

  it 'should mount the engine' do
    expect(destination_root).to have_structure {
      directory 'config' do
        file 'routes.rb' do
          contains "mount G5Authenticatable::Engine => '/g5_auth'"
        end
      end
    }
  end

  it 'should include authorization in the application controller' do
    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'controllers' do
          file 'application_controller.rb' do
            contains 'include G5Authenticatable::Authorization'
          end
        end
      end
    }
  end

  it 'should create the default application policy' do
    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'policies' do
          file 'application_policy.rb' do
            contains 'class ApplicationPolicy < G5Authenticatable::BasePolicy'
          end
        end
      end
    }
  end

  it 'should copy the static 403 error page' do
    expect(destination_root).to have_structure {
      directory 'public' do
        file '403.html' do
          contains 'Access forbidden'
        end
      end
    }
  end

  def setup_routes
    routes = <<-END
      Rails.application.routes.draw do
        resource :home, only: [:show, :index]

        match '/some_path', to: 'controller#action', as: :my_alias

        root to: 'home#index'
      end
    END
    config_dir = File.join(destination_root, 'config')

    FileUtils.mkdir_p(config_dir)
    File.write(File.join(config_dir, 'routes.rb'), routes)
  end

  def setup_application_controller
    controller = <<-END
      class ApplicationController < ActionController::Base
        protect_from_forgery
      end
    END
    controllers_dir = File.join(destination_root, 'app', 'controllers')

    FileUtils.mkdir_p(controllers_dir)
    File.write(File.join(controllers_dir, 'application_controller.rb'), controller)
  end
end
