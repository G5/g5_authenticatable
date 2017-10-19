# frozen_string_literal: true

module RailsApi
  class SecureResourcesController < ApplicationController
    before_action :authenticate_api_user!, unless: :is_navigational_format?
    before_action :authenticate_user!, if: :is_navigational_format?

    def create
      render json: { secure: 'data' }
    end

    def show
      respond_to do |format|
        format.html { render }
        format.json { render json: { secure: 'data' } }
      end
    end
  end
end
