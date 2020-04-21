# frozen_string_literal: true

FactoryBot.define do
  factory :g5_authenticatable_user, class: 'G5Authenticatable::User' do
    sequence(:email) { |n| "test.user#{n}@test.host" }
    provider {'g5'}
    sequence(:uid) { |n| "abc123-#{n}" }
    sequence(:g5_access_token) { |n| "secret_token_#{n}" }
    first_name {'Jane'}
    last_name {'Doe'}
    phone_number {'(555) 867-5309'}
    title {'Minister of Funny Walks'}
    organization_name {'Department of Redundancy Department'}
  end

  factory :g5_authenticatable_super_admin, parent: :g5_authenticatable_user do
    after(:build) do |user|
      user.roles.clear
      user.roles << FactoryBot.build(:g5_authenticatable_super_admin_role)
    end
  end

  factory :g5_authenticatable_admin, parent: :g5_authenticatable_user do
    after(:build) do |user|
      user.roles.clear
      user.roles << FactoryBot.build(:g5_authenticatable_admin_role)
    end
  end

  factory :g5_authenticatable_editor, parent: :g5_authenticatable_user do
    after(:build) do |user|
      user.roles.clear
      user.roles << FactoryBot.build(:g5_authenticatable_editor_role)
    end
  end

  factory :g5_authenticatable_viewer, parent: :g5_authenticatable_user do
    after(:build) do |user|
      user.roles.clear
      user.roles << FactoryBot.build(:g5_authenticatable_viewer_role)
    end
  end
end
