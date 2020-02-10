module G5Authenticatable
  class UserService
    def self.find_or_create_from_access_token_request(request, warden)
      user_fetcher = G5AuthenticatableApi::Services::UserFetcher.new(request.params, request.headers, warden)
      User.create_or_find_from_auth_user(auth_user:       user_fetcher.current_user,
                                         g5_access_token: user_fetcher.access_token)
    end
  end
end