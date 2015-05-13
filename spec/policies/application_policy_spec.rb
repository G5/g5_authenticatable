require 'spec_helper'

describe ApplicationPolicy do
  subject(:policy) { described_class }

  let(:user) { FactoryGirl.create(:g5_authenticatable_user) }
  let(:record) { FactoryGirl.create(:post) }

  permissions :index? do
    it_behaves_like 'a super_admin authorizer'
  end

  permissions :show? do
    context 'when record exists in scope' do
      it 'permits access' do
        expect(policy).to permit(user, record)
      end
    end

    context 'when record does not exist in scope' do
      let(:record) { FactoryGirl.build(:post) }

      it 'denies access' do
        expect(policy).to_not permit(user, record)
      end
    end
  end

  permissions :create? do
    it_behaves_like 'a super_admin authorizer'
  end

  permissions :new? do
    it_behaves_like 'a super_admin authorizer'
  end

  permissions :update? do
    it 'denies access by default' do
      expect(policy).to_not permit(user, record)
    end
  end

  permissions :edit? do
    it 'denies access by default' do
      expect(policy).to_not permit(user, record)
    end
  end

  permissions :destroy? do
    it 'denies access by default' do
      expect(policy).to_not permit(user, record)
    end
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

      it 'is false' do
        expect(super_admin?).to eq(false)
      end
    end

    context 'when user does not have super_admin role' do
      it 'is false' do
        expect(super_admin?).to eq(false)
      end
    end

    context 'when user has the super_admin role' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

      it 'is true' do
        expect(super_admin?).to eq(true)
      end
    end
  end
end
