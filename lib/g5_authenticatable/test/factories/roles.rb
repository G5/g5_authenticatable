# frozen_string_literal: true

FactoryBot.define do
  factory :g5_authenticatable_role, class: 'G5Authenticatable::Role' do
    sequence(:name) { |n| "role_#{n}" }
  end

  factory :g5_authenticatable_super_admin_role,
          parent: :g5_authenticatable_role do
    name 'super_admin'
  end

  factory :g5_authenticatable_admin_role, parent: :g5_authenticatable_role do
    name 'admin'
  end

  factory :g5_authenticatable_editor_role, parent: :g5_authenticatable_role do
    name 'editor'
  end

  factory :g5_authenticatable_viewer_role, parent: :g5_authenticatable_role do
    name 'viewer'
  end

  factory :g5_authenticatable_client_role, parent: :g5_authenticatable_role do
    association :resource, factory: :g5_updatable_client
  end

  factory :g5_authenticatable_client_admin_role,
          parent: :g5_authenticatable_client_role do
    name 'admin'
  end

  factory :g5_authenticatable_client_editor_role,
          parent: :g5_authenticatable_client_role do
    name 'editor'
  end

  factory :g5_authenticatable_client_viewer_role,
          parent: :g5_authenticatable_client_role do
    name 'viewer'
  end

  factory :g5_authenticatable_location_role,
          parent: :g5_authenticatable_role do
    association :resource, factory: :g5_updatable_location
  end

  factory :g5_authenticatable_location_admin_role,
          parent: :g5_authenticatable_location_role do
    name 'admin'
  end

  factory :g5_authenticatable_location_editor_role,
          parent: :g5_authenticatable_location_role do
    name 'editor'
  end

  factory :g5_authenticatable_location_viewer_role,
          parent: :g5_authenticatable_location_role do
    name 'viewer'
  end
end
