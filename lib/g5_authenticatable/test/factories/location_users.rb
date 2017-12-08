# frozen_string_literal: true

FactoryBot.define do
  factory :g5_authenticatable_location_user, parent: :g5_authenticatable_user do
    transient do
      locations nil
      location_count 1
      role_factory :g5_authenticatable_location_role
    end

    after(:create) do |user, evaluator|
      user.roles.clear

      user.roles << if evaluator.locations
                      evaluator.locations.collect do |location|
                        create(evaluator.role_factory, resource: location)
                      end
                    else
                      user.roles << create_list(evaluator.role_factory,
                                                evaluator.location_count)
                    end
    end
  end

  factory :g5_authenticatable_location_admin,
          parent: :g5_authenticatable_location_user do
    transient do
      role_factory :g5_authenticatable_location_admin_role
    end
  end

  factory :g5_authenticatable_location_editor,
          parent: :g5_authenticatable_location_user do
    transient do
      role_factory :g5_authenticatable_location_editor_role
    end
  end

  factory :g5_authenticatable_location_viewer,
          parent: :g5_authenticatable_location_user do
    transient do
      role_factory :g5_authenticatable_location_viewer_role
    end
  end
end
