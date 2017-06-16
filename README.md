# G5 Authenticatable

G5 Authenticatable provides a default authentication solution for G5
Rails applications. This gem configures and mounts
[Devise](https://github.com/plataformatec/devise) with a default User
model, using [OmniAuth](https://github.com/intridea/omniauth) to authenticate
to the G5 Auth server. Helpers are also provided to secure your API methods.

If you are already using Devise with your own model, this is not the
library you are looking for. Consider using the
[devise_g5_authenticatable](https://github.com/G5/devise_g5_authenticatable)
extension directly.

If you have a stand-alone service without a UI, you may not need Devise at
all. Consider using the
[g5_authenticatable_api](https://github.com/G5/g5_authenticatable_api)
library in isolation.

## Current Version

1.0.0.pre.1

## Requirements

* [rails](https://github.com/rails/rails) >= 4.1

## Installation

1. Set the environment variable `DEVISE_SECRET_KEY` to the value
   generated by:

   ```console
   rake secret
   ```

2. Add this line to your application's Gemfile:

   ```ruby
   gem 'g5_authenticatable'
   ```

3. And then execute:

   ```console
   bundle
   ```

4. Run the generator:

   ```console
   rails g g5_authenticatable:install
   ```

   This creates a migration for the new g5_authenticatable_users
   table, and mounts the engine at `/g5_auth`.

5. Update your database:

   ```console
   rake db:migrate db:test:prepare
   ```

## Configuration

### Root route

Devise requires you to define a root route in your application's
`config/routes.rb`. For example:

```ruby
root to: 'home#index'
```

### Registering your OAuth application

1. Visit the auth server admin console and login:
  * For development, visit https://dev-auth.g5search.com/admin
  * For production, visit https://auth.g5search.com/admin
2. Click "New Application"
3. Enter a name that recognizably identifies your application.
4. Enter the redirect URI where the auth server should redirect
   after the user successfully authenticates. It will be
   of the form `http://<your_host>/g5_auth/users/auth/g5/callback`.

   For non-production environments, this redirect URI does not have to
   be publicly accessible, but it must be accessible from the browser
   where you will be testing (so using something like
   http://localhost:3000/g5_auth/users/auth/g5/callback is fine if your browser
   and client application server are both local).

   If you are using the production G5 Auth server, the redirect URI **MUST**
   use HTTPS.
5. For a trusted G5 application, check the "Auto-authorize?" checkbox. This
   skips the OAuth authorization step where the user is prompted to explicitly
   authorize the client application to access the user's data.
6. Click "Submit" to obtain the client application's credentials.

### Environment variables

Once you have your OAuth 2.0 credentials, you'll need to set the following
environment variables for your client application:

* `G5_AUTH_CLIENT_ID` - the OAuth 2.0 application ID from the auth server
* `G5_AUTH_CLIENT_SECRET` - the OAuth 2.0 application secret from the auth server
* `G5_AUTH_REDIRECT_URI` - the OAuth 2.0 redirect URI registered with the auth server
* `G5_AUTH_ENDPOINT` - the endpoint URL (without any path info) for the G5 auth server.
  Generally, this will be set to either `https://dev-auth.g5search.com` or
  `https://auth.g5search.com` (the default).

If you need to make server-to-server API calls that are not associated with an
end user, you can also set up a default user's credentials with:

* `G5_AUTH_USERNAME` - the G5 auth server user name
* `G5_AUTH_PASSWORD` - the G5 auth server user's password

### Token validation

By default, G5 Authenticatable only validates access tokens on incoming API
requests. If you are relying on session-based authentication instead, it is
possible for the local application's session to remain active after the
global access token has been revoked.

If you want to guarantee that the local session is destroyed when the access
token is revoked, add the following to
`config/initializers/g5_authenticatable.rb`:

```ruby
G5Authenticatable.strict_token_validation = true
```

## Usage

### Controller filters and helpers

G5 Authenticatable installs all of the usual devise controllers and helpers.
To set up a controller that requires authentication, use this before_action:

```ruby
before_action :authenticate_user!
```

To verify if a user is signed in, use the following helper:

```ruby
user_signed_in?
```

To access the model instance for the currently signed-in user:

```ruby
current_user
```

To access scoped session storage:

```ruby
user_session
```

### Securing an engine (e.g. sidekiq or resque web UI)

To use G5 Auth to secure another Rails engine mounted within your application,
modify your `config/routes.rb` file like so:

```ruby
# To allow any authenticated user to access the mounted engine
authenticate :user do
  mount Sidekiq::Web => '/sidekiq'
end

# To restrict access to a particular user role
authenticate :user, ->(user) { user.has_role?(:super_admin) } do
  mount Sidekiq::Web => '/sidekiq'
end
```

Note that some additional configuration may be necessary, depending on the
engine which you are securing. For instance, sidekiq web tries to manage its
own independent session store, which must be disabled by adding this line to
your `config/initializers/sidekiq.rb` file:

```ruby
Sidekiq::Web.set(:sessions, false)
```

### Route helpers

There are several generic helper methods for session and omniauth
URLs. To sign in:

```ruby
new_session_path(:user)
```

To sign out:

```ruby
destroy_session_path(:user)
```

There are also generic helpers for the OmniAuth paths, though you
are unlikely to ever use these directly. The OmniAuth entry point
is mounted at:

```ruby
g5_authorize_path(:user)
```

And the OmniAuth callback is:

```ruby
g5_callback_path(:user)
```

You may be more familiar with Devise's generated scoped URL helpers.
These are still available, but are isolated to the engine's namespace.
For example:

```ruby
g5_authenticatable.new_user_session_path
g5_authenticatable.destroy_user_session_path
```

### Access token ###

When a user authenticates, their OAuth access token will be stored on
the local user:

```ruby
current_user.g5_access_token
```

This is to support server-to-server API calls with G5 services that are
protected by OAuth.

### Securing an API ###

#### Grape ####

If you include `G5AuthenticatableApi::Helpers::Grape`, you can use the
`authenticate_user!` method to protect your API actions:

```ruby
class MyApi < Grape::API
  helpers G5AuthenticatableApi::GrapeHelpers

  before { authenticate_user! }

  # ...
end
```

#### Rails ####

You can secure API actions that respond to json using the `authenticate_api_user!`
method:

```ruby
class MyResourcesController < ApplicationController
  respond_to :json

  before_action :authenticate_api_user!

  def get
    @resource = MyResource.find(params[:id])
    respond_with(@resource)
  end
end
```

#### Secure Clients ####

If you have an ember application, no client-side changes are necessary to use a
secure API method, as long as the action that serves your ember app requires
users to authenticate with G5 via devise.

Any non-browser clients must use token-based authentication. In contexts where
a valid OAuth 2.0 access token is not already available, you may request a new
token from the G5 Auth server using
[g5_authentication_client](https://github.com/G5/g5_authentication_client).
Clients may pass the token to secure API actions either in the HTTP
Authorization header, or in a request parameter named `access_token`.

For more details, see the documentation for
[g5_authenticatable_api](https://github.com/G5/g5_authenticatable_api).

### Authorization ###

#### User Roles ####

User roles are defined on the auth server and automatically populated in the local
model layer when a user logs in:

```ruby
current_user.roles
# => #<ActiveRecord::Associations::CollectionProxy [#<G5Authenticatable::Role id: 1, name: "viewer", ...>]>
```

We use [rolify](https://github.com/RolifyCommunity/rolify) for role management,
which provides an interface for querying role assignments:

```ruby
current_user.has_role?(:editor)
```

G5 currently supports four different roles: `:super_admin`, `:admin`,
`:editor`, and `:viewer` (the default role).

Two convenience methods have been added to the `G5Authenticatable::User`:

* `user.clients` will return a list of clients that the user has any access to. Will return all clients if the user has a global role
* `user.client_roles` will return a list of roles that relate directly to a client

#### Policies and Scopes ####

G5 Authenticatable uses [pundit](https://github.com/elabs/pundit) to encapsulate
the authorization logic in policy objects. The pundit documentation contains a much
more thorough explanation of how to define and use policies, but a quick overview
is provided here.

The G5 Authenticatable generator created an `app/policies/application_policy.rb`
file in your project:

```ruby
class ApplicationPolicy < G5Authenticatable::BasePolicy
  class Scope < BaseScope
  end
end
```

The `G5Authenticatable::BasePolicy` and `G5Authenticatable::BasePolicy::BaseScope`
implement a set of default authorization rules that essentially forbids access
to all actions on all model instances unless the user has the `:super_admin`
role. It also provides a set of helper methods for checking user roles:
`super_admin?`, `admin?`, `editor?`, or `viewer?`.

In order to implement a custom policy for one of your application's models, you
can create a new policy in the `app/policies` directory. For instance, if you
have a `Widget` model, and you want to also grant permissions to update that
model to users with `:admin` or `:editor` roles:

```ruby
# app/policies/widget_policy.rb

class WidgetPolicy < ApplicationPolicy
  def update?
    super_admin? || admin? || editor?
  end
end
```

You also have access to the record being authorized, and can define rules based
on that. For instance, if you want to restrict `Widget` deletion based on both
user role and some flag on the `Widget` instance to be deleted:

```ruby
# app/policies/widget_policy.rb

class WidgetPolicy < ApplicationPolicy
  def destroy?
    (super_admin? || admin?) && !record.published?
  end
end
```

In order to implement data-level authorization, you can define a custom scope
within your policy. The scope `resolve` method should only return the records
to which the current user has access. You have access to the current `user` and
also the `scope` object (defaults to the record class). For instance, if a user
must be the owner of a widget in order to access it, but super admins are allowed
to access all widgets:

```ruby
# app/policies/widget_policy.rb

class WidgetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.has_role?(:super_admin?)
        scope.all
      else
        scope.where(owner_id: user.id)
      end
    end
  end
end
```

If you want to apply the same authorization logic across all models in your
application, you can define them in `ApplicationPolicy` or
`ApplicationPolicy::Scope`.

#### Using Policies in Controllers ####

You can use the `authorize` method in your controller to ensure that the
current user has access to the current action on a particular model instance.
For instance, in your controller:

```ruby
class WidgetsController < ApplicationController
  # ...

  def update
    @widget = Widget.find(params[:id])
    authorize(@widget)

    if @widget.update_attributes(widget_params)
      flash[:notice] = "Widget successfully updated."
    end

    respond_with(@widget)
  end
end
```

In this example, the `authorize` method will automatically lookup the correct policy
and populate it with the `current_user` and the model argument, and then call the
`update?` method on it, based on the current action name.

You can directly access the policy scope to look up the records to which the
current user has access by using the `policy_scope` method:

```ruby
class WidgetsController < ApplicationController
  # ...

  def index
    @widgets = policy_scope(Widget)
  end
```

In this example, the `policy_scope` method will automatically look up the
`WidgetPolicy::Scope`, populate it with the current user and `Widget` record
class, and call the scope `resolve` method to retrieve the results.

#### Using Policies in Views ####

Sometimes, you want to be able to access authorization logic inside Rails views.
For instance, you may want to hide the link to edit a record if the user does
not have access to update that record. In these cases, you can use the `policy`
method to lookup the instance of the policy directly:

```erb
<% if policy(@widget).update? %>
  <%= link_to 'Edit', edit_widget_path(@widget) %>
<% end %>
```

You can also call the `policy_scope` method inside views.

If you are not rendering your views within your Rails application (for
instance, if you are using an Ember front-end), then you will have to build
your own API for querying policy information in order to access this
functionality directly in your view.

### Test Helpers ###

G5 Authenticatable currently only supports [rspec-rails](https://github.com/rspec/rspec-rails).
Helpers and shared contexts are provided for integration testing secure pages
and API methods.

#### Prerequisites ####

Because the test helpers are optional, bundler will not automatically install
these dependencies. You will have to add the following gems to your own Gemfile:

* [rspec-rails](https://github.com/rspec/rspec-rails)
* [factory_girl_rails](https://github.com/thoughtbot/factory_girl_rails)
* [webmock](https://github.com/bblimke/webmock)

#### Incompatibilities ####

There are [known issues](https://github.com/G5/g5_authenticatable/issues/27) using the
auth test helpers with [selenium-webdriver](http://docs.seleniumhq.org/projects/webdriver/)
and the Firefox browser. As such, selenium-webdriver is not officially supported by
the G5 Authenticatable library.

If you are using [capybara](https://github.com/jnicklas/capybara) to run your
integration tests, we highly recommend using
[poltergeist](https://github.com/teampoltergeist/poltergeist) for PhantomJS as
your javascript driver instead.

#### Installation ####

To automatically mix in helpers to your feature and request specs, include the
following line in your `spec/rails_helper.rb`, after your app and rspec-rails
have been loaded:

```ruby
require 'g5_authenticatable/rspec'
```

Note that the example code assumes you are using Rspec 3 metadata syntax. If you are
using Rspec 2.x, you can either:

* Enable this syntax with the following config in your `spec/spec_helper.rb`:

  ```ruby
  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
  end
  ```

* Or you can replace every instance of a bare symbol in the metadata with a full
  key-value pair. For example:

  ```ruby
  # This won't work out of the box with Rspec 2
  context 'my secure context', :auth do
    it 'can see my secrets'
  end

  # But this will...
  context 'my secure context', auth: true do
    it 'can see my secrets'
  end
  ```

#### Feature Specs ####

The easiest way to use g5_authenticatable in feature specs is through
the shared auth context. This context creates a user (available via
`let(:user)`) and then authenticates as that user. To use the shared
context, simply include `:auth` in the RSpec metadata for your example
or group:

```ruby
context 'my secure context', :auth do
  it 'can access some resource' do
    visit('the place')
    expect(page).to ...
  end
end
```

If you prefer, you can use the helper methods from
`G5Authenticatable::Test::FeatureHelpers` instead of relying on the shared
context. For example:

```ruby
describe 'my page' do
  context 'with valid user credentials' do
    let(:my_user) { create(:g5_authenticatable_user, email: 'my.email@test.host') }
    before { stub_g5_omniauth(my_user) }

    it 'should display the secure page' do
      visit('the page')
      expect(page).to ...
    end
  end

  context 'with invalid OAuth credentials' do
    before { stub_g5_invalid_credentials }

    it 'should display an error' do
      visit('the page')
      expect(page). to ...
    end
  end

  context 'when user has previously authenticated' do
    let(:my_user) { create(:g5_authenticatable_user, email: 'my.email@test.host') }
    before { visit_path_and_login_with('some other path', my_user) }

    it 'should display the thing I expect' do
      visit('the page')
      expect(page).to ...
    end
  end
end
```

#### Request Specs ####

You can test API methods that have been secured with g5_authenticatable by
using the auth request shared context. This context creates a user (available
via `let(:user)`) and then automatically authenticates as that user. To use the
shared context, simply tag your example group with the `:auth_request` RSpec
metadata:

```ruby
describe 'my secure API', :auth_request do
  it 'can access some resource' do
    get '/api/v1/resource'
    expect(response).to ...
  end
end
```

Alternatively, you may wish to use the helper methods from
`G5Authenticatable::Test::RequestHelpers` directly:

```ruby
describe 'my secure API' do
  context 'when user is authenticated' do
    before { login_user }

    it 'can access some resource' do
      get '/api/v1/resource'
      expect(response).to be_success
    end
  end

  context 'when there is no authenticated user' do
    before { logout_user }

    it 'cannot access the resource' do
      get '/api/v1/resource'
      expect(response.status).to eq(401)
    end
  end
end
```

#### Controller Specs ####

You can test controller specs that have been secured with g5_authenticatable
by using the controller spec shared context.  This context creates a user
available via `let(:user)` and then automatically authenticates as that user.
To use the shared context, tag your example group with the `:auth_controller`
Rspec metadata:

```ruby
describe 'my secure action' do
  context 'when the user is authenticated' do
    it 'can access some secure path' do
      get :my_action
      expect(response). to be_success
    end
  end

  context 'when there is no authenticated user', :auth_controller do
    it 'cannot access the secure path' do
      get :my_action
      expect(reponse).to be_redirect
    end
  end
end
```

#### Token Validation Helpers ####

If you tag your examples with auth metadata (e.g. `:auth`, `:auth_request` or
`:auth_controller`), then the shared context will automatically take care of
any stubs required to support strict token validation.

However, if you are using the auth test helper methods directly, and you have
enabled strict token validation, then you will need to use the methods in
`G5Authenticatable::Test::TokenValidationHelpers` to stub external calls to
validate the access token.

For example, in a feature spec, you could use the `stub_valid_access_token`
method like so:

```ruby
describe 'my page' do
  let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

  before do
    stub_g5_omniauth(user)
    stub_valid_access_token(user.g5_access_token)
  end

  it 'should let me in'
end
```

As another example, in a request spec, you could stub a revoked access
token using the `stub_invalid_access_token` helper:

```ruby
describe 'my API call' do
  let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

  before { login_user }

  context 'when token becomes invalid after login' do
    before { stub_invalid_access_token(user.g5_access_token) }

    it 'should return 401'
  end

  context 'when token remains valid after login' do
    before { stub_valid_access_token(user.g5_access_token) }

    it 'should return 200'
  end
end
```

The same token validation helpers are also available in controller
specs, or anywhere else that authentication logic may be invoked.

### Purging local user data

G5 Authenticatable automatically maintains user data locally via the
`G5Authenticatable::User` model. This local data can be purged
using the following rake task:

```console
$ rake g5_authenticatable:purge_users
```

Executing this task does not affect any remote user data on the
auth server.

It is especially important to purge the local user data
when reconfiguring a client application to use a different auth endpoint
(for example, when cloning a demo environment from production).

## Examples

### Protecting a particular Rails controller action

You can use all of the usual options to `before_action` for more fine-grained
control over where authentication is required. For example, to require
authentication only to edit a resource while leaving all other actions
unsecured:

```ruby
class MyResourcesController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]

  # ...
end
```

### Adding a link to sign in

In your view template, add the following:

```html+erb
<%= link_to('Login', new_session_path(:user)) %>
```

### Adding a link to sign out

In your view template, add the following:

```html+erb
<%= link_to('Logout', destroy_session_path(:user)) %>
```

### Selectively securing Grape API methods

To selectively secure an individual API method:

```ruby
class MyApi < Grape::API
  get :my_secure_action do
    authenticate_user!
    {message: 'secure action'}
  end

  get :anonymous_action do
    {message: 'hello world'}
  end
end
```

### Securing a Rails controller that mixes API and website methods

Within a Rails controller, the `authenticate_api_user!` looks for a token
in the request and returns a 401 when a user cannot be authenticated.
In contrast, devise's `authenticate_user!` filter assumes that client is a
web browser, and redirects to the auth server sign in page when there is
no authenticated user.

Most of the time, there is a clear delineation between controllers
that service API requests and controllers that service website requests,
but not always. If you have a mixture of API and website actions in
your controller, you can selectively apply the auth filters based on
the request format:

```ruby
class MyMixedUpController < ApplicationController
  before_action :authenticate_api_user!, unless: :is_navigational_format?
  before_action :authenticate_user!, if: :is_navigational_format?

  respond_to :html, :json

  def show
    resource = MyResource.find(params[:id])
    respond_with(resource)
  end
end
```

In the code above, we assume that HTML requests come from a client that
can display the auth server's sign in page to the end user, while all other
formats are assumed to be API requests.

If HTML requests do not imply a client capable of providing a user to interact with
a signup form, you can try something like this:

```ruby
class MyMixedUpController < ApplicationController
  before_action :authenticate_api_user!, if: :is_api_request?
  before_action :authenticate_user!, unless: :is_api_request?

  respond_to :html

  def show
    resource = MyResource.find(params[:id])
    respond_with(resource)
  end

  private

  def is_api_request?
	!G5Authenticatable::TokenValidator.new(params, headers).access_token.nil?
  end
end
```

## Authors

* Maeve Revels / [@maeve](https://github.com/maeve)
* Rob Revels / [@sleverbor](https://github.com/sleverbor)

## Contributing

1. [Fork it](https://github.com/G5/g5_authenticatable/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write your code and **specs**
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

If you find bugs, have feature requests or questions, please
[file an issue](https://github.com/G5/g5_authenticatable/issues).

### Specs

Before running the specs for the first time, you will need to initialize the
database for the test Rails application.

```console
$ cp spec/dummy/config/database.yml.sample spec/dummy/config/database.yml
$ RAILS_ENV=test bundle exec rake app:db:setup
```

To execute the entire test suite:

```console
$ bundle exec rspec spec
```

## License

Copyright (c) 2014 G5

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
