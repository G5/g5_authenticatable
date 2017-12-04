# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'g5_authenticatable:purge_users' do
  include_context 'rake'

  context 'when there are no local users' do
    it 'should not raise any errors' do
      expect { task.invoke }.to_not raise_error
    end

    it 'should not leave any user data in the db' do
      task.invoke
      expect(G5Authenticatable::User.count).to eq(0)
    end
  end

  context 'when there is one local user' do
    let!(:user) { FactoryBot.create(:g5_authenticatable_user) }

    it 'should delete the user data from the db' do
      expect { task.invoke }.to change { G5Authenticatable::User.count }.from(1).to(0)
    end
  end

  context 'when there are multiple local users' do
    let!(:user1) { FactoryBot.create(:g5_authenticatable_user) }
    let!(:user2) { FactoryBot.create(:g5_authenticatable_user) }

    it 'should delete the user data from the db' do
      expect { task.invoke }.to change { G5Authenticatable::User.count }.from(2).to(0)
    end
  end
end
