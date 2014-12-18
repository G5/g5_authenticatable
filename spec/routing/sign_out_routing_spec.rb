require 'spec_helper'

describe 'Sign out routes' do
  routes {G5Authenticatable::Engine.routes}

  it 'should route GET /g5_auth/users/sign_out' do
    expect(get('/users/sign_out')).to route_to(controller: 'g5_authenticatable/sessions',
                                               action: 'destroy')
  end
end
