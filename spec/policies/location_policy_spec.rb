# frozen_string_literal: true

require 'rails_helper'

RSpec.describe G5Updatable::LocationPolicy do
  subject(:policy) { described_class }

  let(:user) { FactoryGirl.create(:g5_authenticatable_user) }
  let(:user2) { FactoryGirl.create(:g5_authenticatable_user) }

  let!(:client_1) { FactoryGirl.create(:g5_updatable_client) }
  let!(:client_2) { FactoryGirl.create(:g5_updatable_client) }

  let!(:location_1) do
    FactoryGirl.create(:g5_updatable_location, client: client_1)
  end
  let!(:location_2) do
    FactoryGirl.create(:g5_updatable_location, client: client_1)
  end

  let!(:location_3) do
    FactoryGirl.create(:g5_updatable_location, client: client_2)
  end
  let!(:location_4) do
    FactoryGirl.create(:g5_updatable_location, client: client_2)
  end

  before do
    user.roles = []
    user.save!
    user2.add_role(:viewer, location_1)
  end

  describe '.resolve' do
    subject do
      G5Updatable::LocationPolicy::Scope.new(user, G5Updatable::Location)
                                        .resolve
    end

    context 'with global role' do
      before { user.add_role :admin }
      it 'returns all locations' do
        expect(subject.length).to eq(4)
        expect(subject).to include(location_1)
        expect(subject).to include(location_2)
        expect(subject).to include(location_3)
      end
    end

    context 'with location role' do
      before { user.add_role(:admin, location_1) }
      it 'returns a single location' do
        expect(subject.length).to eq(1)
        expect(subject).to include(location_1)
      end
    end

    context 'with many client roles' do
      before do
        user.add_role(:admin, location_1)
        user.add_role(:admin, location_2)
        user.add_role(:admin, location_3)
      end
      it 'returns all assigned clients' do
        expect(subject.length).to eq(3)
        expect(subject).to include(location_1)
        expect(subject).to include(location_2)
        expect(subject).to include(location_3)
      end
    end

    context 'with no role' do
      it 'returns no locations' do
        expect(subject.length).to eq(0)
      end
    end
  end
end
