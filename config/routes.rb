# frozen_string_literal: true

G5Authenticatable::Engine.routes.draw do
  devise_for :users, class_name: 'G5Authenticatable::User',
                     module: :devise,
                     controllers: { sessions: 'g5_authenticatable/sessions' }

  devise_scope :user do
    delete '/users/sign_out', to: redirect('users/sign_out')
  end

  get '/auth_error', to: 'error#auth_error'
end
