# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Signing in' do
  let(:user) { FactoryBot.create(:g5_authenticatable_viewer) }

  context 'from a login link' do
    subject(:login) { click_link 'Login' }

    before { visit root_path }

    context 'when user exists locally' do
      before do
        OmniAuth.config.mock_auth[:g5] = OmniAuth::AuthHash.new(
          uid: user.uid,
          provider: user.provider,
          info: {
            email: user.email,
            name: "#{updated_first_name} #{updated_last_name}",
            first_name: updated_first_name,
            last_name: updated_last_name,
            phone: updated_phone_number
          },
          credentials: {
            token: updated_access_token,
            expires: true,
            expires_at: Time.now + 1000
          },
          extra: {
            title: updated_title,
            organization_name: updated_organization_name,
            roles: [{ name: updated_role.name, type: 'GLOBAL', urn: nil }],
            raw_info: {}
          }
        )
      end

      let(:updated_first_name) { "Updated #{user.first_name}" }
      let(:updated_last_name) { "Updated #{user.last_name}" }
      let(:updated_phone_number) { "#{user.phone_number} x1234" }
      let(:updated_title) { "Updated #{user.title}" }
      let(:updated_organization_name) { "Updated #{user.organization_name}" }
      let(:updated_access_token) { "updated-#{user.g5_access_token}-123" }
      let(:updated_role) do
        FactoryBot.create(:g5_authenticatable_super_admin_role)
      end

      it 'should sign in the user successfully' do
        login
        expect(page).to have_content('Signed in successfully.')
      end

      it 'should redirect the user to the root path' do
        login
        expect(current_path).to eq(root_path)
      end

      it 'should not create a new user' do
        expect { login }.to_not change { G5Authenticatable::User.count }
      end

      it 'should not update the user email' do
        login
        expect(page).to have_content(user.email)
      end

      it 'should update the first name' do
        login
        expect(page).to have_content(updated_first_name)
      end

      it 'should update the last name' do
        login
        expect(page).to have_content(updated_last_name)
      end

      it 'should update the phone number' do
        login
        expect(page).to have_content(updated_phone_number)
      end

      it 'should update the title' do
        login
        expect(page).to have_content(updated_title)
      end

      it 'should update the organization name' do
        login
        expect(page).to have_content(updated_organization_name)
      end

      it 'should update the access token' do
        login
        expect(page).to have_content(updated_access_token)
      end

      it 'should assign the updated role' do
        login
        expect(page).to have_content(updated_role.name)
      end

      it 'should unassign the previous role' do
        old_role = user.roles.first
        login
        expect(page).to_not have_content(old_role.name)
      end
    end

    context 'when user does not exist locally' do
      before do
        full_name = [user_attributes[:first_name],
                     user_attributes[:last_name]].join(' ')
        OmniAuth.config.mock_auth[:g5] = OmniAuth::AuthHash.new(
          uid: user_attributes[:uid],
          provider: user_attributes[:provider],
          info: {
            email: user_attributes[:email],
            name: full_name,
            first_name: user_attributes[:first_name],
            last_name: user_attributes[:last_name],
            phone: user_attributes[:phone_number]
          },
          credentials: {
            token: user_attributes[:g5_access_token],
            expires: true,
            expires_at: Time.now + 1000
          },
          extra: {
            title: user_attributes[:title],
            organization_name: user_attributes[:organization_name],
            roles: [{ name: role_attributes[:name], type: 'GLOBAL', urn: nil }],
            raw_info: {}
          }
        )
      end

      let(:user_attributes) do
        FactoryBot.attributes_for(:g5_authenticatable_user)
      end
      let(:role_attributes) do
        FactoryBot.attributes_for(:g5_authenticatable_editor_role)
      end

      it 'should sign in the user successfully' do
        login
        expect(page).to have_content('Signed in successfully.')
      end

      it 'should redirect the user to the root path' do
        login
        expect(current_path).to eq(root_path)
      end

      it 'should create the user locally' do
        expect { login }.to change { G5Authenticatable::User.count }.by(1)
      end

      it 'should save the user email' do
        login
        expect(page).to have_content(user_attributes[:email])
      end

      it 'should save the user first_name' do
        login
        expect(page).to have_content(user_attributes[:first_name])
      end

      it 'should save the user last_name' do
        login
        expect(page).to have_content(user_attributes[:last_name])
      end

      it 'should save the user phone_number' do
        login
        expect(page).to have_content(user_attributes[:phone_number])
      end

      it 'should save the user token' do
        login
        expect(page).to have_content(user_attributes[:g5_access_token])
      end

      it 'should save the user title' do
        login
        expect(page).to have_content(user_attributes[:title])
      end

      it 'should save the user organization_name' do
        login
        expect(page).to have_content(user_attributes[:organization_name])
      end

      it 'should save the user role' do
        login
        expect(page).to have_content(role_attributes[:name])
      end
    end
  end

  context 'when visiting a protected page' do
    before do
      visit_path_and_login_with(protected_page_path, user)
    end

    it 'should sign in the user successfully' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'should redirect the user to the protected page' do
      expect(current_path).to eq(protected_page_path)
    end
  end
end
