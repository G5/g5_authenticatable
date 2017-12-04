# frozen_string_literal: true

require 'rails_helper'

RSpec.describe G5Authenticatable::ImpersonateSessionable do
  let!(:user) { FactoryBot.create(:g5_authenticatable_user) }

  class MyImpersponateSessionableTest
    include G5Authenticatable::ImpersonateSessionable
  end

  let(:service_instance) { MyImpersponateSessionableTest.new }

  describe '#impersonation_user?' do
    subject(:impersonation_user) { service_instance.send(:impersonation_user?) }

    before do
      expect(service_instance).to receive(:impersonation_user).and_return(user)
    end

    it { is_expected.to be_truthy }
  end

  describe '#impersonation_user' do
    subject(:impersonation_user) { service_instance.send(:impersonation_user) }

    before do
      expect(service_instance).to receive(:impersonate_admin_uid)
        .and_return(user.uid)
    end

    it { is_expected.to eq(user) }
  end

  describe '#user_to_impersonate' do
    subject(:user_to_impersonate) do
      service_instance.send(:user_to_impersonate)
    end

    before do
      expect(service_instance).to receive(:impersonating_user_uid)
        .and_return(user.uid)
    end

    it { is_expected.to eq(user) }
  end

  describe '#able_to_impersonate?' do
    subject(:able_to_impersonate) do
      service_instance.send(:able_to_impersonate?, user, user2)
    end

    context 'having a super admin and any other user' do
      let!(:user) do
        user = FactoryBot.create(:g5_authenticatable_user)
        user.add_role(:super_admin)
        user
      end
      let!(:user2) { FactoryBot.create(:g5_authenticatable_user) }

      it { is_expected.to eq(true) }
    end

    context 'having an admin' do
      let!(:user) do
        user = FactoryBot.create(:g5_authenticatable_user)
        user.add_role(:admin)
        user
      end

      context 'assuming a super admin' do
        let!(:user2) do
          user = FactoryBot.create(:g5_authenticatable_user)
          user.add_role(:super_admin)
          user
        end

        it { is_expected.to eq(false) }
      end

      context 'assuming another admin' do
        let!(:user2) do
          user = FactoryBot.create(:g5_authenticatable_user)
          user.add_role(:admin)
          user
        end

        it { is_expected.to eq(true) }
      end

      context 'assuming a regular user' do
        let!(:user2) { FactoryBot.create(:g5_authenticatable_user) }

        it { is_expected.to eq(true) }
      end
    end

    context 'providing no user' do
      context 'when user to impersonate is nil' do
        let(:user) { FactoryBot.create(:g5_authenticatable_super_admin) }
        let(:user2) {}

        it { is_expected.to eq(false) }
      end

      context 'when signed-in user is nil' do
        let(:user) {}
        let(:user2) { FactoryBot.create(:g5_authenticatable_user) }

        it { is_expected.to eq(false) }
      end

      context 'when both users are nil' do
        let(:user) {}
        let(:user2) {}

        it { is_expected.to eq(false) }
      end
    end
  end

  describe '#user_by_uid' do
    subject(:user_by_uid) { service_instance.send(:user_by_uid, uid) }

    context 'having an existing uid' do
      let(:uid) { user.uid }
      it { is_expected.to eq(user) }
    end

    context 'having a no existing uid' do
      let(:uid) { 'some-random-text' }
      it { is_expected.to be_nil }
    end
  end
end
