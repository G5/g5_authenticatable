# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Application Configuration' do
  it 'appends access_token to the implementing apps filter_parameters' do
    expect(Dummy::Application.config.filter_parameters)
      .to include(:access_token)
  end
end
