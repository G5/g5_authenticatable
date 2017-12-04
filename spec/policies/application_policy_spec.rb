# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject(:policy) { described_class }

  let(:user) { FactoryBot.create(:g5_authenticatable_user) }
  let(:record) { FactoryBot.create(:post) }

  permissions :index? do
    it_behaves_like 'a super_admin authorizer'
  end

  permissions :show? do
    context 'when user is a super_admin' do
      let(:user) { FactoryBot.create(:g5_authenticatable_super_admin) }

      context 'when record exists in scope' do
        it { is_expected.to permit(user, record) }
      end

      context 'when record does not exist in scope' do
        let(:record) { FactoryBot.build(:post) }

        it { is_expected.to_not permit(user, record) }
      end
    end

    context 'when user is not a super_admin' do
      it { is_expected.to_not permit(user, record) }
    end
  end

  permissions :create? do
    it_behaves_like 'a super_admin authorizer'
  end

  permissions :new? do
    it_behaves_like 'a super_admin authorizer'
  end

  permissions :update? do
    it_behaves_like 'a super_admin authorizer'
  end

  permissions :edit? do
    it_behaves_like 'a super_admin authorizer'
  end

  permissions :destroy? do
    it_behaves_like 'a super_admin authorizer'
  end

  describe '#scope' do
    subject(:scope) { policy.new(user, record).scope }

    it 'should look up the correct scope based on the record class' do
      post_scope = PostPolicy::Scope.new(user, record.class)
      expect(scope).to eq(post_scope.resolve)
    end
  end

  describe '#super_admin?' do
    subject(:super_admin?) { policy.new(user, record).super_admin? }

    context 'when there is no user' do
      let(:user) {}

      it { is_expected.to eq(false) }
    end

    context 'when user does not have super_admin role' do
      it { is_expected.to eq(false) }
    end

    context 'when user has the super_admin role' do
      let(:user) { FactoryBot.create(:g5_authenticatable_super_admin) }

      it { is_expected.to eq(true) }
    end
  end

  describe '#admin?' do
    subject(:admin?) { policy.new(user, record).admin? }

    context 'when there is no user' do
      let(:user) {}

      it { is_expected.to eq(false) }
    end

    context 'when user does not have admin role' do
      it { is_expected.to eq(false) }
    end

    context 'when user has the admin role' do
      let(:user) { FactoryBot.create(:g5_authenticatable_admin) }

      it { is_expected.to eq(true) }
    end
  end

  describe '#editor?' do
    subject(:editor?) { policy.new(user, record).editor? }

    context 'when there is no user' do
      let(:user) {}

      it { is_expected.to eq(false) }
    end

    context 'when user does not have editor role' do
      it { is_expected.to eq(false) }
    end

    context 'when user has the editor role' do
      let(:user) { FactoryBot.create(:g5_authenticatable_editor) }

      it { is_expected.to eq(true) }
    end
  end

  describe '#viewer?' do
    subject(:viewer?) { policy.new(user, record).viewer? }

    context 'when there is no user' do
      let(:user) {}

      it { is_expected.to eq(false) }
    end

    context 'when user does not have viewer role' do
      let(:user) { FactoryBot.create(:g5_authenticatable_editor) }

      it { is_expected.to eq(false) }
    end

    context 'when user has the viewer role' do
      let(:user) { FactoryBot.create(:g5_authenticatable_viewer) }

      it { is_expected.to eq(true) }
    end
  end

  describe '#global_role?' do
    subject(:global_role?) { policy.new(user, record).global_role? }

    let(:scoped_role) do
      FactoryBot.create(:g5_authenticatable_role, name: role_name,
                                                   resource: resource)
    end
    let(:resource) { FactoryBot.create(:g5_updatable_client) }

    context 'when there is no user' do
      it { is_expected.to eq(false) }
    end

    context 'when the user is a global super admin' do
      let(:user) { FactoryBot.create(:g5_authenticatable_super_admin) }

      it { is_expected.to eq(true) }
    end

    context 'when the user is a global admin' do
      let(:user) { FactoryBot.create(:g5_authenticatable_admin) }

      it { is_expected.to eq(true) }
    end

    context 'when the user is a global editor' do
      let(:user) { FactoryBot.create(:g5_authenticatable_editor) }

      it { is_expected.to eq(true) }
    end

    context 'when the user is a global viewer' do
      let(:user) { FactoryBot.create(:g5_authenticatable_viewer) }

      it { is_expected.to eq(true) }
    end

    context 'when user is a scoped admin' do
      let(:role_name) { :admin }
      before { user.roles << scoped_role }

      it { is_expected.to eq(false) }
    end

    context 'when user is a scoped editor' do
      let(:role_name) { :editor }
      before { user.roles << scoped_role }

      it { is_expected.to eq(false) }
    end

    context 'when user is a scoped viewer' do
      let(:role_name) { :viewer }
      before { user.roles << scoped_role }

      it { is_expected.to eq(false) }
    end
  end
end
