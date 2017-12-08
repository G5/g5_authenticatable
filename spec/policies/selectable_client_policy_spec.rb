# frozen_string_literal: true

require 'rails_helper'

RSpec.describe G5Updatable::SelectableClientPolicy do
  subject(:policy) { described_class }

  let(:user) { FactoryBot.create(:g5_authenticatable_user) }
  let(:user2) { FactoryBot.create(:g5_authenticatable_user) }

  before do
    user.roles = []
    user.save!
    user2.add_role(:viewer, client_1)
  end

  let!(:client_1) { FactoryBot.create(:g5_updatable_client) }
  let!(:client_2) { FactoryBot.create(:g5_updatable_client) }
  let!(:client_3) { FactoryBot.create(:g5_updatable_client) }

  describe '.resolve' do
    subject do
      G5Updatable::SelectableClientPolicy::Scope.new(user, G5Updatable::Client)
                                                .resolve
    end

    let!(:location_1) do
      FactoryBot.create(:g5_updatable_location, client: client_1)
    end
    let!(:location_2) do
      FactoryBot.create(:g5_updatable_location, client: client_1)
    end

    let!(:location_3) do
      FactoryBot.create(:g5_updatable_location, client: client_2)
    end
    let!(:location_4) do
      FactoryBot.create(:g5_updatable_location, client: client_2)
    end

    context 'with global role' do
      before { user.add_role :admin }
      it 'returns all clients' do
        expect(subject.length).to eq(3)
        expect(subject).to include(client_1)
        expect(subject).to include(client_2)
        expect(subject).to include(client_3)
      end
    end

    context 'with role for location and for client that location belongs to' do
      before do
        user.add_role :admin, location_1
        user.add_role :admin, client_1
      end
      it 'returns 1 client' do
        expect(subject.length).to eq(1)
        expect(subject).to include(client_1)
      end
    end

    context 'with role for location and unrelated client' do
      before do
        user.add_role :admin, location_1
        user.add_role :admin, client_2
      end

      it 'returns 1 client' do
        expect(subject.length).to eq(2)
        expect(subject).to include(client_1)
        expect(subject).to include(client_2)
      end
    end

    context 'with a client role' do
      before { user.add_role :admin, client_2 }

      it 'returns 1 client' do
        expect(subject.length).to eq(1)
        expect(subject).to include(client_2)
      end
    end

    context 'with a location role' do
      before { user.add_role :admin, location_1 }

      it 'returns 1 client' do
        expect(subject.length).to eq(1)
        expect(subject).to include(client_1)
      end
    end
  end
end
