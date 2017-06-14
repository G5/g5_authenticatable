# frozen_string_literal: true

require 'spec_helper'

RSpec.describe G5Authenticatable do
  it 'should have a version' do
    expect(G5Authenticatable::VERSION).to_not be_blank
  end
end
