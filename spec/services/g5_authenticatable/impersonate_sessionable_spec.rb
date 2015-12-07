require 'spec_helper'

describe G5Authenticatable::ImpersonateSessionable do
  let!(:user) { FactoryGirl.create(:g5_authenticatable_user) }

  class MyImpersponateSessionableTest
    include G5Authenticatable::ImpersonateSessionable
  end

  let(:service_instance) { MyImpersponateSessionableTest.new }

  describe '#impersonation_user?' do
    subject(:impersonation_user) { service_instance.send(:impersonation_user?) }

    before do
      expect(service_instance).to receive(:impersonation_user).and_return(user)
    end

    it { expect(impersonation_user).to be_truthy }
  end

  describe '#impersonation_user' do
    subject(:impersonation_user) { service_instance.send(:impersonation_user) }

    before do
      expect(service_instance).to receive(:impersonate_admin_uid).and_return(user.uid)
    end

    it { expect(impersonation_user).to eq(user) }
  end

  describe '#user_to_impersonate' do
    subject(:user_to_impersonate) { service_instance.send(:user_to_impersonate) }

    before do
      expect(service_instance).to receive(:impersonating_user_uid).and_return(user.uid)
    end

    it { expect(user_to_impersonate).to eq(user) }
  end

  describe '#able_to_impersonate?' do
    subject(:able_to_impersonate) { service_instance.send(:able_to_impersonate?, user, user2) }

    context 'having a super admin and any other user' do
      let!(:user) do
        user = FactoryGirl.create(:g5_authenticatable_user)
        user.add_role(:super_admin)
        user
      end
      let!(:user2) { FactoryGirl.create(:g5_authenticatable_user) }

      it { expect(able_to_impersonate).to eq(true) }
    end

    context 'having an admin' do
      let!(:user) do
        user = FactoryGirl.create(:g5_authenticatable_user)
        user.add_role(:admin)
        user
      end

      context 'assuming a super admin' do
        let!(:user2) do
          user = FactoryGirl.create(:g5_authenticatable_user)
          user.add_role(:super_admin)
          user
        end

        it { expect(able_to_impersonate).to eq(false) }
      end

      context 'assuming another admin' do
        let!(:user2) do
          user = FactoryGirl.create(:g5_authenticatable_user)
          user.add_role(:admin)
          user
        end

        it { expect(able_to_impersonate).to eq(true) }
      end

      context 'assuming a regular user' do
        let!(:user2) { FactoryGirl.create(:g5_authenticatable_user) }

        it { expect(able_to_impersonate).to eq(true) }
      end
    end

    context 'providing no user' do
      it { expect(service_instance.send(:able_to_impersonate?, user, nil)).to eq(false) }

      it { expect(service_instance.send(:able_to_impersonate?, nil, user)).to eq(false) }

      it { expect(service_instance.send(:able_to_impersonate?, nil, nil)).to eq(false) }
    end
  end

  describe '#user_by_uid' do
    subject(:user_by_uid) { service_instance.send(:user_by_uid, uid) }

    context 'having an existing uid' do
      let(:uid) { user.uid }
      it { expect(user_by_uid).to eq(user) }
    end

    context 'having a no existing uid' do
      let(:uid) { 'some-random-text' }
      it { expect(user_by_uid).to be_nil }
    end
  end
end
