# frozen_string_literal: true

RSpec.shared_examples_for 'a super_admin authorizer' do
  context 'when user is an admin' do
    let(:user) { FactoryBot.create(:g5_authenticatable_admin) }

    it 'denies access' do
      expect(policy).to_not permit(user, record)
    end
  end

  context 'when user is an editor' do
    let(:user) { FactoryBot.create(:g5_authenticatable_editor) }

    it 'denies access' do
      expect(policy).to_not permit(user, record)
    end
  end

  context 'when user is a viewer' do
    let(:user) { FactoryBot.create(:g5_authenticatable_user) }

    it 'denies access' do
      expect(policy).to_not permit(user, record)
    end
  end

  context 'when user has super_admin role' do
    let(:user) { FactoryBot.create(:g5_authenticatable_super_admin) }

    it 'permits access' do
      expect(policy).to permit(user, record)
    end
  end
end
