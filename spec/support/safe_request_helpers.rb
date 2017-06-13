# frozen_string_literal: true

# Methods for submitting test requests that are safe to use
# under both rails 4.x and 5.x
module SafeRequestHelpers
  def safe_get(endpoint, params = nil, headers = nil)
    safe_request(:get, endpoint, params, headers)
  end

  def safe_post(endpoint, params = nil, headers = nil)
    safe_request(:post, endpoint, params, headers)
  end

  def safe_put(endpoint, params = nil, headers = nil)
    safe_request(:put, endpoint, params, headers)
  end

  def safe_delete(endpoint, params = nil, headers = nil)
    safe_request(:delete, endpoint, params, headers)
  end

  def safe_request(method, endpoint, params, headers)
    if Rails.version.starts_with?('4')
      send(method, endpoint, params, headers)
    else
      options = { params: params }
      options[:headers] = headers if headers
      send(method, endpoint, **options)
    end
  end
end

RSpec.configure do |config|
  config.include SafeRequestHelpers, type: :controller
  config.include SafeRequestHelpers, type: :request
end
