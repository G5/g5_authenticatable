# frozen_string_literal: true

require 'rails_helper'

RSpec.describe G5Authenticatable::ErrorController do
  routes { G5Authenticatable::Engine.routes }

  it 'should route GET /g5_auth/auth_error path' do
    expect(get: '/auth_error')
      .to route_to(controller: 'g5_authenticatable/error', action: 'auth_error')
  end

  it 'should generate a helper' do
    expect(auth_error_path).to eq('/g5_auth/auth_error')
  end
end
