# frozen_string_literal: true

require 'rails_helper'

RSpec.describe G5Authenticatable::User do
  subject { user }
  let(:user) { G5Authenticatable::User.create(user_attributes) }
  let(:user_attributes) { FactoryBot.attributes_for(:g5_authenticatable_user) }

  it { is_expected.to have_and_belong_to_many(:roles) }

  it 'should expose the email' do
    expect(user.email).to eq(user_attributes[:email])
  end

  it 'should expose the user provider' do
    expect(user.provider).to eq(user_attributes[:provider])
  end

  it 'should expose the user uid' do
    expect(user.uid).to eq(user_attributes[:uid])
  end

  it 'should expose a g5_access_token' do
    expect(user.g5_access_token).to eq(user_attributes[:g5_access_token])
  end

  it 'should initialize the sign_in_count' do
    expect(user.sign_in_count).to eq(0)
  end

  it 'should expose a method for updating tracked attributes' do
    expect(user).to respond_to(:update_tracked_fields!)
  end

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }

  it 'should support timeouts' do
    expect(user.timeout_in).to be > 0
  end

  it 'should expose the first_name' do
    expect(user.first_name).to eq(user_attributes[:first_name])
  end

  it 'should expose the last_name' do
    expect(user.last_name).to eq(user_attributes[:last_name])
  end

  it 'should expose the phone number' do
    expect(user.phone_number).to eq(user_attributes[:phone_number])
  end

  it 'should expose the title' do
    expect(user.title).to eq(user_attributes[:title])
  end

  it 'should expose the organization name' do
    expect(user.organization_name).to eq(user_attributes[:organization_name])
  end

  describe '#attributes_from_auth' do
    subject(:attributes_from_auth) { user.attributes_from_auth(auth_data) }

    let(:auth_data) do
      full_name = [new_user_attributes[:first_name],
                   new_user_attributes[:last_name]].join(' ')
      OmniAuth::AuthHash.new(
        'uid' => new_user_attributes[:uid],
        'provider' => new_user_attributes[:provider],
        'info' => {
          'email' => new_user_attributes[:email],
          'name' => full_name,
          'first_name' => new_user_attributes[:first_name],
          'last_name' => new_user_attributes[:last_name],
          'phone' => new_user_attributes[:phone_number]
        },
        'credentials' => {
          'token' => new_user_attributes[:g5_access_token],
          'expires' => true,
          'expires_at' => Time.now + 1000
        },
        'extra' => {
          'title' => new_user_attributes[:title],
          'organization_name' => new_user_attributes[:organization_name],
          'roles' => [
            { 'name' => new_role_attributes[:name],
              'type' => 'GLOBAL',
              'urn' => nil }
          ],
          'raw_info' => {}
        }
      )
    end

    let(:new_user_attributes) do
      FactoryBot.attributes_for(:g5_authenticatable_user)
    end
    let(:new_role_attributes) do
      FactoryBot.attributes_for(:g5_authenticatable_role)
    end

    it 'has the correct uid' do
      expect(attributes_from_auth[:uid]).to eq(new_user_attributes[:uid])
    end

    it 'has the correct provider' do
      expect(attributes_from_auth[:provider])
        .to eq(new_user_attributes[:provider])
    end

    it 'has the correct first_name' do
      expect(attributes_from_auth[:first_name])
        .to eq(new_user_attributes[:first_name])
    end

    it 'has the correct last_name' do
      expect(attributes_from_auth[:last_name])
        .to eq(new_user_attributes[:last_name])
    end

    it 'has the correct email' do
      expect(attributes_from_auth[:email]).to eq(new_user_attributes[:email])
    end

    it 'has the correct phone_number' do
      expect(attributes_from_auth[:phone_number])
        .to eq(new_user_attributes[:phone_number])
    end

    it 'has the correct title' do
      expect(attributes_from_auth[:title]).to eq(new_user_attributes[:title])
    end

    it 'has the correct organization_name' do
      expect(attributes_from_auth[:organization_name])
        .to eq(new_user_attributes[:organization_name])
    end
  end

  describe '.new_with_session' do
    subject(:new_user) do
      G5Authenticatable::User.new_with_session(params, session)
    end

    let(:params) { {} }
    let(:auth_data) do
      full_name = [new_user_attributes[:first_name],
                   new_user_attributes[:last_name]].join(' ')
      OmniAuth::AuthHash.new(
        'provider' => new_user_attributes[:provider],
        'info' => {
          'email' => new_user_attributes[:email],
          'name' => full_name,
          'first_name' => new_user_attributes[:first_name],
          'last_name' => new_user_attributes[:last_name],
          'phone' => new_user_attributes[:phone_number]
        },
        'credentials' => {
          'token' => new_user_attributes[:g5_access_token],
          'expires' => true,
          'expires_at' => Time.now + 1000
        },
        'extra' => {
          'title' => new_user_attributes[:title],
          'organization_name' => new_user_attributes[:organization_name],
          'roles' => [
            { 'name' => new_role_attributes[:name],
              'type' => 'GLOBAL',
              'urn' => nil }
          ],
          'raw_info' => {}
        }
      )
    end

    let(:new_user_attributes) do
      FactoryBot.attributes_for(:g5_authenticatable_user)
    end
    let(:new_role_attributes) do
      FactoryBot.attributes_for(:g5_authenticatable_role)
    end

    context 'when there is auth data in the session' do
      let(:session) do
        { 'omniauth.auth' => auth_data }
      end

      context 'with UID' do
        before do
          auth_data['uid'] = new_user_attributes[:uid]
        end
        it 'should set the uid from the session data' do
          expect(new_user.uid).to eq(new_user_attributes[:uid])
        end
      end

      context 'without UID' do
        it "won't set the uid from the session data" do
          expect(new_user.uid).to be_nil
        end
      end

      it 'should initialize a new user' do
        expect(new_user).to be_a_new_record
      end

      it 'should not persist the user' do
        expect { new_user }.to_not change { G5Authenticatable::User.count }
      end

      it 'should set the provider from the session data' do
        expect(new_user.provider).to eq(new_user_attributes[:provider])
      end

      it 'should set the email from the session data' do
        expect(new_user.email).to eq(new_user_attributes[:email])
      end

      it 'should set the first_name from the session data' do
        expect(new_user.first_name).to eq(new_user_attributes[:first_name])
      end

      it 'should set the last_name from the session data' do
        expect(new_user.last_name).to eq(new_user_attributes[:last_name])
      end

      it 'should set the phone_number from the session data' do
        expect(new_user.phone_number).to eq(new_user_attributes[:phone_number])
      end

      it 'should set the title from the session data' do
        expect(new_user.title).to eq(new_user_attributes[:title])
      end

      it 'should set the organization_name from the session data' do
        expect(new_user.organization_name)
          .to eq(new_user_attributes[:organization_name])
      end

      it 'should assign the role from the session data' do
        expect(new_user).to have_role(new_role_attributes[:name])
      end
    end

    context 'when there is no auth data in the session' do
      let(:session) { {} }

      it 'should initialize a new user' do
        expect(new_user).to be_a_new_record
      end

      it 'should not persist the user' do
        expect { new_user }.to_not change { G5Authenticatable::User.count }
      end

      it 'should not set the uid' do
        expect(new_user.uid).to be_nil
      end

      it 'should set the provider to the default value' do
        expect(new_user.provider).to eq('g5')
      end

      it 'should not set the email' do
        expect(new_user.email).to be_blank
      end

      it 'should not assign a role to the user' do
        expect(new_user.roles).to be_empty
      end
    end
  end

  describe '.find_and_update_for_g5_oauth' do
    subject(:updated_user) do
      G5Authenticatable::User.find_and_update_for_g5_oauth(auth_data)
    end

    let(:user_attributes) do
      FactoryBot.attributes_for(:g5_authenticatable_user,
                                 first_name: nil,
                                 last_name: nil,
                                 phone_number: nil,
                                 title: nil,
                                 organization_name: nil)
    end
    let(:role_name) { :my_role }

    before do
      user
      user.add_role(role_name)
    end

    let(:auth_data) do
      OmniAuth::AuthHash.new(
        'provider' => user_attributes[:provider],
        'uid' => user_attributes[:uid],
        'info' => {
          'email' => updated_attributes[:email],
          'first_name' => updated_attributes[:first_name],
          'last_name' => updated_attributes[:last_name],
          'phone' => updated_attributes[:phone_number]
        },
        'credentials' => {
          'token' => updated_attributes[:g5_access_token],
          'expires' => true,
          'expires_at' => Time.now + 1000
        },
        'extra' => {
          'title' => updated_attributes[:title],
          'organization_name' => updated_attributes[:organization_name],
          'roles' => [
            { name: updated_role_name, type: 'GLOBAL', urn: nil }
          ],
          'raw_info' => {}
        }
      )
    end

    context 'when user info is the same' do
      let(:updated_attributes) do
        user_attributes.merge(g5_access_token: 'updatedtoken42')
      end
      let(:updated_role_name) { role_name }

      it 'should update the access token' do
        expect { updated_user }.to change { user.reload.g5_access_token }
          .to(updated_attributes[:g5_access_token])
      end

      it 'should return the updated user' do
        expect(updated_user).to eq(user.reload)
      end

      it 'should not change the user email' do
        expect { updated_user }.to_not change { user.reload.email }
      end

      it 'should not change the user first_name' do
        expect { updated_user }.to_not change { user.reload.first_name }
      end

      it 'should not change the user last_name' do
        expect { updated_user }.to_not change { user.reload.last_name }
      end

      it 'should not change the user phone_number' do
        expect { updated_user }.to_not change { user.reload.phone_number }
      end

      it 'should not change the user title' do
        expect { updated_user }.to_not change { user.reload.title }
      end

      it 'should not change the user organization_name' do
        expect { updated_user }.to_not change { user.reload.organization_name }
      end

      it 'should not change the user roles' do
        expect { updated_user }.to_not change { user.reload.roles }
      end
    end

    context 'when user info has changed' do
      let(:updated_attributes) do
        {
          uid: user.uid,
          provider: user.provider,
          email: 'updated.email@test.host',
          g5_access_token: 'updatedtoken42',
          first_name: 'Updated First Name',
          last_name: 'Updated Last Name',
          phone_number: '555.555.5555 x123',
          title: 'Recently Promoted',
          organization_name: 'Updated Department'
        }
      end

      let(:updated_role_name) { 'super_admin' }

      it 'should update the access token' do
        expect { updated_user }.to change { user.reload.g5_access_token }
          .to(updated_attributes[:g5_access_token])
      end

      it 'should return the updated user' do
        expect(updated_user).to eq(user.reload)
      end

      it 'should not change the uid' do
        expect { updated_user }.to_not change { user.reload.uid }
      end

      it 'should not change the provider' do
        expect { updated_user }.to_not change { user.reload.provider }
      end

      it 'should update the email' do
        expect { updated_user }.to change { user.reload.email }
          .to(updated_attributes[:email])
      end

      it 'should update the first name' do
        expect { updated_user }.to change { user.reload.first_name }
          .to(updated_attributes[:first_name])
      end

      it 'should update the last name' do
        expect { updated_user }.to change { user.reload.last_name }
          .to(updated_attributes[:last_name])
      end

      it 'should update the phone number' do
        expect { updated_user }.to change { user.reload.phone_number }
          .to(updated_attributes[:phone_number])
      end

      it 'should update the title' do
        expect { updated_user }.to change { user.reload.title }
          .to(updated_attributes[:title])
      end

      it 'should update the organization_name' do
        expect { updated_user }.to change { user.reload.organization_name }
          .to(updated_attributes[:organization_name])
      end

      it 'should unassign the old role' do
        expect(updated_user).to_not have_role(role_name)
      end

      it 'should assign the new role' do
        expect(updated_user).to have_role(updated_role_name)
      end
    end
  end

  describe '#add_role' do
    subject(:add_role) { user.add_role(role_name) }

    context 'when role already exists' do
      let(:role) { FactoryBot.create(:g5_authenticatable_role) }
      let(:role_name) { role.name }

      it 'should assign a role to the user' do
        expect { add_role }.to change { user.roles.count }.by(1)
      end

      it 'should assign the existing role' do
        add_role
        expect(user.roles).to include(role)
      end
    end

    context 'when role does not exist' do
      let(:role_name) { :some_new_role }

      it 'should assign a role to the user' do
        expect { add_role }.to change { user.roles.count }.by(1)
      end

      it 'should create the new role' do
        add_role
        expect(G5Authenticatable::Role.exists?(name: role_name)).to be_truthy
      end
    end
  end

  describe '#has_role?' do
    subject(:has_role?) { user.has_role?(role_name) }
    let(:role_name) { :my_role }

    context 'when user has been assigned the role' do
      before { user.add_role(role_name) }

      it 'should return true' do
        expect(has_role?).to be_truthy
      end
    end

    context 'when user has not been assigned the role' do
      it 'should return false' do
        expect(has_role?).to be_falsey
      end
    end
  end

  describe '#update_roles_from_auth' do
    before do
      user.roles = []
      user.save!
    end

    let(:user2) { G5Authenticatable::User.create(user_attributes) }
    let(:user_attributes2) do
      FactoryBot.attributes_for(:g5_authenticatable_user)
    end

    let!(:resource) { FactoryBot.create(:g5_updatable_client) }

    let(:auth_data) do
      OmniAuth::AuthHash.new(
        'provider' => user_attributes[:provider],
        'uid' => user_attributes[:uid],
        'info' => {
          'email' => user_attributes[:email],
          'first_name' => user_attributes[:first_name],
          'last_name' => user_attributes[:last_name],
          'phone' => user_attributes[:phone_number]
        },
        'credentials' => {
          'token' => user_attributes[:g5_access_token],
          'expires' => true,
          'expires_at' => Time.now + 1000
        },
        'extra' => {
          'title' => user_attributes[:title],
          'organization_name' => user_attributes[:organization_name],
          'roles' => roles,
          'raw_info' => {}
        }
      )
    end

    context 'with global role' do
      let(:roles) do
        [{ name: 'admin', type: 'GLOBAL', urn: nil }]
      end

      it 'will add a global role' do
        expect { user.update_roles_from_auth(auth_data) }
          .to change { user.roles.length }.from(0).to(1)
        expect(user.roles.first.name).to eq('admin')
        expect(user.roles.first.resource).to be_nil
      end
    end

    context 'with a scoped role' do
      let(:roles) do
        [{ name: 'viewer', type: resource.class.name, urn: resource.urn }]
      end

      it 'will add a scoped role' do
        expect { user.update_roles_from_auth(auth_data) }
          .to change { user.roles.length }.from(0).to(1)
        expect(user.roles.first.name).to eq('viewer')
        expect(user.roles.first.resource_id).to eq(resource.id)
        expect(user.roles.first.resource_type).to eq(resource.class.name)
      end
    end

    context 'with a more than 1 role' do
      let(:roles) do
        [
          { name: 'viewer', type: resource.class.name, urn: resource.urn },
          { name: 'admin', type: 'GLOBAL', urn: nil }
        ]
      end

      it 'will add a scoped role' do
        expect { user.update_roles_from_auth(auth_data) }
          .to change { user.roles.length }.from(0).to(2)
      end
    end

    context 'with an un-existing scoped role URL' do
      let(:non_existing_urn) { 'some-non-existing-urn' }

      let(:roles) do
        [{ name: 'viewer', type: 'G5Updatable::Client', urn: non_existing_urn }]
      end

      it 'will add a scoped role' do
        expect { user.update_roles_from_auth(auth_data) }
          .to_not change { user.roles.length }
      end
    end

    context 'with 0 roles' do
      let(:roles) { [] }

      it 'will add a scoped role' do
        expect { user.update_roles_from_auth(auth_data) }
          .to_not change { user.roles.length }.from(0)
      end
    end

    context 'with a bad role type' do
      let(:roles) do
        [
          { name: 'viewer', type: resource.class.name, urn: resource.urn },
          { name: 'viewer', type: 'BadResource', urn: resource.urn }
        ]
      end

      it 'will skip the bad role' do
        expect { user.update_roles_from_auth(auth_data) }
          .to change { user.roles.length }.from(0).to(1)
        expect(user.roles.first.name).to eq('viewer')
        expect(user.roles.first.resource_id).to eq(resource.id)
        expect(user.roles.first.resource_type).to eq(resource.class.name)
      end
    end
  end
end
