require 'spec_helper'

describe G5Authenticatable::Authorization, type: :controller do
  controller(ActionController::Base) do
    include G5Authenticatable::Authorization

    def index
      raise Pundit::NotAuthorizedError.new(query: 'index?', record: 'mock_record')
    end
  end

  it 'should mixin the authorize method' do
    expect(controller).to respond_to(:authorize)
  end

  it 'should mixin the policy_scope method' do
    expect(controller).to respond_to(:policy_scope)
  end

  describe '#user_not_authorized' do
    subject(:user_not_authorized) { get :index, format: format }

    context 'when format is json' do
      let(:format) { :json }

      it 'is forbidden' do
        user_not_authorized
        expect(response).to be_forbidden
      end

      it 'renders the json error message' do
        user_not_authorized
        expect(JSON.parse(response.body)).to eq({'error' => 'Access forbidden'})
      end
    end

    context 'when format is html' do
      let(:format) { :html }
      it 'is forbidden' do
        user_not_authorized
        expect(response).to be_forbidden
      end

      it 'renders the static 403.html' do
        user_not_authorized
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
  end
end
