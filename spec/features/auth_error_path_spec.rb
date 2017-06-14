# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'error path' do
  context 'when there is an error at the oauth server' do
    before do
      stub_g5_invalid_credentials
    end

    it 'should redirect to the error path' do
      visit(protected_page_path)
      expect(current_path).to eq('/g5_auth/auth_error')
    end

    it 'should not use the application layout' do
      visit(protected_page_path)
      expect(page).to_not have_title('Dummy')
    end
  end
end
