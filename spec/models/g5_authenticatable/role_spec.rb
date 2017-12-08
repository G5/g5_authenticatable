# frozen_string_literal: true

require 'rails_helper'

RSpec.describe G5Authenticatable::Role do
  subject { role }
  let(:role) { G5Authenticatable::Role.new(role_attributes) }
  let(:role_attributes) { FactoryBot.attributes_for(:g5_authenticatable_role) }

  it { is_expected.to have_and_belong_to_many(:users) }
  it { is_expected.to belong_to(:resource) }

  it 'should expose the name attribute' do
    expect(role.name).to eq(role_attributes[:name])
  end

  describe '.global' do
    subject(:global) { G5Authenticatable::Role.global }
    let!(:global_role) { user.roles.first }
    let(:user) { FactoryBot.create(:g5_authenticatable_viewer) }

    let!(:scoped_role) do
      FactoryBot.create(:g5_authenticatable_role,
                         resource: user)
    end

    it 'should match one role' do
      expect(global.count).to eq(1)
    end

    it 'should only match the unscoped role' do
      expect(global.first).to eq(global_role)
    end
  end

  describe '.class_scoped' do
    subject(:class_scoped) do
      G5Authenticatable::Role.class_scoped(G5Authenticatable::User)
    end
    let!(:global_role) { FactoryBot.create(:g5_authenticatable_role) }
    let!(:class_scoped_role) do
      FactoryBot.create(:g5_authenticatable_role,
                         resource_type: 'G5Authenticatable::User')
    end
    let!(:instance_scoped_role) do
      FactoryBot.create(:g5_authenticatable_role, resource: user)
    end
    let(:user) { FactoryBot.create(:g5_authenticatable_user) }

    it 'should match one role' do
      expect(class_scoped.count).to eq(1)
    end

    it 'should only match the class scoped role' do
      expect(class_scoped.first).to eq(class_scoped_role)
    end
  end

  describe '.instance_scoped' do
    subject(:instance_scoped) { G5Authenticatable::Role.instance_scoped(user) }
    let!(:global_role) { FactoryBot.create(:g5_authenticatable_role) }
    let!(:class_scoped_role) do
      FactoryBot.create(:g5_authenticatable_role,
                         resource_type: 'G5Authenticatable::User')
    end

    let!(:user_scoped_role) do
      FactoryBot.create(:g5_authenticatable_role, resource: user)
    end
    let(:user) { FactoryBot.create(:g5_authenticatable_user) }

    let!(:other_user_scoped_role) do
      FactoryBot.create(:g5_authenticatable_role, resource: other_user)
    end
    let(:other_user) { FactoryBot.create(:g5_authenticatable_user) }

    it 'should match one role' do
      expect(instance_scoped.count).to eq(1)
    end

    it 'should only match the role scoped to this user instance' do
      expect(instance_scoped.first).to eq(user_scoped_role)
    end
  end
end
