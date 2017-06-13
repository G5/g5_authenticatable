# frozen_string_literal: true

require 'spec_helper'

describe 'a secure Grape API' do
  subject(:api_call) { safe_get '/api/secure_resource' }

  context 'with an authenticated user', :auth_request do
    it 'should be successful' do
      api_call
      expect(response.status).to eq(200)
    end
  end

  context 'without an authenticated user' do
    it 'should be unauthorized' do
      api_call
      expect(response.status).to eq(401)
    end
  end
end
