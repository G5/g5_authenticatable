# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    sequence(:content) { |n| "This is my post #{n}" }
    association :author, factory: :g5_authenticatable_user
  end
end
