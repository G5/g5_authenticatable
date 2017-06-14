# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Post do
  subject { post }
  let(:post) { FactoryGirl.create(:post) }

  it { is_expected.to belong_to(:author) }

  it 'should have a G5Authenticatable::User as the author' do
    expect(post.author).to be_a(G5Authenticatable::User)
  end
end
