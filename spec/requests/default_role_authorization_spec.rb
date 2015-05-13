require 'spec_helper'

describe 'Default role-based authorization API' do
  let(:json) { JSON.parse(response.body) }

  describe 'GET /posts', :auth_request do
    subject(:get_posts) { get posts_path, format: :json }

    let!(:post) { FactoryGirl.create(:post, author: user) }
    let!(:other_post) { FactoryGirl.create(:post) }

    before { get_posts }

    context 'when user is a super_admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

      it 'returns ok' do
        expect(response).to be_ok
      end

      it 'includes all posts' do
        expect(json).to contain_exactly(
          hash_including('id' => post.id,
                         'author_id' => post.author.id,
                         'content' => post.content),
          hash_including('id' => other_post.id,
                         'author_id' => other_post.author.id,
                         'content' => other_post.content)
        )
      end
    end

    context 'when user is not a super_admin' do
      it 'returns forbidden' do
        expect(response).to be_forbidden
      end
    end
  end

  describe 'POST /posts', :auth_request do
    subject(:create_post) { post posts_path, post: post_params, format: :json }

    let(:post_params) do
      {content: post_obj.content, author_id: post_obj.author.id}
    end
    let(:post_obj) { FactoryGirl.build(:post, author: user) }

    context 'when user is a super_admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

      it 'returns ok' do
        create_post
        expect(response).to be_created
      end

      it 'creates a post' do
        expect { create_post }.to change { Post.count }.by(1)
      end
    end

    context 'when user is not a super_admin' do
      it 'returns forbidden' do
        create_post
        expect(response).to be_forbidden
      end

      it 'does not create a post' do
        expect { create_post }.to_not change { Post.count }
      end
    end
  end

  describe 'PUT /posts/:id', :auth_request do
    subject(:update_post) do
      put post_path(post.id), post: post_params, format: :json
    end

    let(:post_params) do
      {content: 'some brand new content', author_id: post.author.id}
    end
    let(:post) { FactoryGirl.create(:post, author: user) }

    context 'when user is a super_admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

      it 'returns ok' do
        update_post
        expect(response).to be_http_no_content
      end

      it 'updates the post' do
        expect { update_post }.to change { post.reload.content }
      end
    end

    context 'when user is not a super_admin' do
      it 'returns forbidden' do
        update_post
        expect(response).to be_forbidden
      end

      it 'does not update the post' do
        expect { update_post }.to_not change { post.reload.content }
      end
    end
  end
end
