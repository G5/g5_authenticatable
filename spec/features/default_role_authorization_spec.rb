# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Default role-based authorization UI' do
  describe 'Posts index' do
    let(:visit_posts_index) { visit_path_and_login_with(posts_path, user) }

    let!(:post) { FactoryGirl.create(:post, author: user) }
    let!(:other_post) { FactoryGirl.create(:post) }

    before { visit_posts_index }

    context 'when authenticated user is a super admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

      it 'renders the posts index page' do
        expect(current_path).to eq(posts_path)
      end

      it 'shows the first post' do
        expect(page).to have_content(post.content)
      end

      it 'shows the second post' do
        expect(page).to have_content(other_post.content)
      end
    end

    context 'when authenticated user is not a super admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      it 'displays an error message' do
        expect(page).to have_content(/forbidden/i)
      end

      it 'does not show the first post' do
        expect(page).to_not have_content(post.content)
      end

      it 'does not show the second post' do
        expect(page).to_not have_content(other_post.content)
      end
    end
  end

  describe 'Show post' do
    let(:show_post) { visit_path_and_login_with(post_path(post.id), user) }

    let!(:post) { FactoryGirl.create(:post, author: user) }

    before { show_post }

    context 'when authenticated user is a super_admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

      it 'renders the show post page' do
        expect(current_path).to eq(post_path(post.id))
      end

      it 'shows the post content' do
        expect(page).to have_content(post.content)
      end
    end

    context 'when authenticated user is not a super_admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      it 'displays an error message' do
        expect(page).to have_content(/forbidden/i)
      end

      it 'does not show the post content' do
        expect(page).to_not have_content(post.content)
      end
    end
  end

  describe 'New post' do
    let(:visit_new_post) { visit_path_and_login_with(new_post_path, user) }

    before { visit_new_post }

    context 'when authenticated user is a super admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

      it 'renders the new post page' do
        expect(current_path).to eq(new_post_path)
      end

      it 'renders a form that accepts post content' do
        expect(page).to have_field('Content')
      end
    end

    context 'when authenticated user is not a super admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      it 'displays an error message' do
        expect(page).to have_content(/forbidden/i)
      end

      it 'does not render a form that accepts post content' do
        expect(page).to_not have_field('Content')
      end
    end
  end

  describe 'Create post' do
    subject(:create_post) { click_button 'Create Post' }

    before do
      visit_path_and_login_with(new_post_path, user)
      fill_in 'Content', with: post.content
    end

    let(:post) { FactoryGirl.build(:post, author: user) }
    let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

    context 'when authenticated user is a super admin' do
      it 'renders the flash message' do
        create_post
        expect(page).to have_content('Post was successfully created.')
      end

      it 'renders the post content' do
        create_post
        expect(page).to have_content(post.content)
      end

      it 'creates a post in the db' do
        expect { create_post }.to change { Post.count }.by(1)
      end
    end

    context 'when authenticated user is not a super admin on form submission' do
      before do
        user.roles.clear
      end

      it 'displays an error message' do
        create_post
        expect(page).to have_content(/forbidden/i)
      end

      it 'does not create a post' do
        expect { create_post }.to_not change { Post.count }
      end
    end
  end

  describe 'Edit post' do
    subject(:edit_post) do
      visit_path_and_login_with(edit_post_path(post.id), user)
    end
    before { edit_post }

    let(:post) { FactoryGirl.create(:post, author: user) }

    context 'when authenticated user is a super admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

      it 'renders the edit post page' do
        expect(current_path).to eq(edit_post_path(post.id))
      end

      it 'renders a form that accepts post content' do
        expect(page).to have_field('Content', with: post.content)
      end
    end

    context 'when authenticated user is not a super admin' do
      let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

      it 'displays an error message' do
        expect(page).to have_content(/forbidden/i)
      end

      it 'does not render a form that accepts post content' do
        expect(page).to_not have_field('Content')
      end
    end
  end

  describe 'Update post' do
    subject(:update_post) { click_button 'Update Post' }

    before do
      visit_path_and_login_with(edit_post_path(post.id), user)
      fill_in 'Content', with: new_content
    end

    let(:post) { FactoryGirl.create(:post, author: user) }
    let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }
    let(:new_content) { 'My updated post content' }

    context 'when authenticated user is a super admin' do
      it 'renders the flash message' do
        update_post
        expect(page).to have_content('Post was successfully updated.')
      end

      it 'renders the post content' do
        update_post
        expect(page).to have_content(new_content)
      end
    end

    context 'when authenticated user is not a super admin on form submission' do
      before do
        user.roles.clear
      end

      it 'displays an error message' do
        update_post
        expect(page).to have_content(/forbidden/i)
      end

      it 'does not update post content' do
        update_post
        expect(page).to_not have_content(new_content)
      end
    end
  end

  describe 'Delete post' do
    subject(:delete_post) { click_link 'Destroy' }

    let!(:post) { FactoryGirl.create(:post, author: user) }
    let(:user) { FactoryGirl.create(:g5_authenticatable_super_admin) }

    before { visit_path_and_login_with(posts_path, user) }

    context 'when authenticated user is a super admin' do
      it 'renders the flash message' do
        delete_post
        expect(page).to have_content('Post was successfully destroyed.')
      end

      it 'deletes the post' do
        expect { delete_post }.to change { Post.count }.by(-1)
      end
    end

    context 'when authenticated user is not a super admin' do
      before { user.roles.clear }

      it 'displays an error message' do
        delete_post
        expect(page).to have_content(/forbidden/i)
      end

      it 'does not delete the post' do
        expect { delete_post }.to_not change { Post.count }
      end
    end
  end
end
