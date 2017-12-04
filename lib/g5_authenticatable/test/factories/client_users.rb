# frozen_string_literal: true

FactoryBot.define do
  factory :g5_authenticatable_client_user, parent: :g5_authenticatable_user do
    transient do
      clients nil
      client_count 1
      role_factory :g5_authenticatable_client_role
    end

    after(:create) do |user, evaluator|
      user.roles.clear

      user.roles << if evaluator.clients
                      evaluator.clients.collect do |client|
                        create(evaluator.role_factory, resource: client)
                      end
                    else
                      create_list(evaluator.role_factory,
                                  evaluator.client_count)
                    end
    end
  end

  factory :g5_authenticatable_client_admin,
          parent: :g5_authenticatable_client_user do
    transient do
      role_factory :g5_authenticatable_client_admin_role
    end
  end

  factory :g5_authenticatable_client_editor,
          parent: :g5_authenticatable_client_user do
    transient do
      role_factory :g5_authenticatable_client_editor_role
    end
  end

  factory :g5_authenticatable_client_viewer,
          parent: :g5_authenticatable_client_user do
    transient do
      role_factory :g5_authenticatable_client_viewer_role
    end
  end
end
