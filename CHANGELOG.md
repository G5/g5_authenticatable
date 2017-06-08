## v1.0.0.pre.1 (TBD)

* **Backwards incompatible changes**
  * Dropped support for rails < 4.1
  * The `:g5_authenticatable_user` factory no longer assigns a default role to
  the user. If you specifically need a user with a global viewer role, use the
  new `:g5_authenticatable_viewer` factory instead.
* Bug fixes
  * Fixed problem with route generation in devise failure app
* Deprecations
  * The `has_global_role?` method on `G5Authenticatable::BasePolicy` and
  `G5Authenticatable::BasePolicy::BaseScope` has been deprecated in favor of
  `global_role?`

## v0.9.0 (2016-11-03)

* Refactor custom mapping logic into devise_g5_authenticatable callbacks
  ([#47](https://github.com/G5/g5_authenticatable/pull/47))

## v0.8.0 (2016-03-07)

* Location role policies
  ([#46](https://github.com/G5/g5_authenticatable/pull/46))

## v0.7.5.beta (2016-01-15)

* Fixes bug that granted higher permissions when the resource for a scoped roles didn't exist.

## v0.7.4 (2015-12-09)

* Adds Impersonate (Assume) Devise Strategy and Concern to handle access to session stored values
* Handles the ability and rules to impersonate a user providing his unique ID
* Adds the UID from the session and request to be used by the Auth Workflow when present

## v0.7.3 (2015-11-30)
* Upgrade to devise_g5_authenticatable to fix regression bug https://github.com/G5/devise_g5_authenticatable/pull/23
* Upgrade to omniauth_g5 to fix regression bug https://github.com/G5/omniauth-g5/pull/10

## v0.7.2 (2015-06-23)

* Removed pinned g5_updatalbe version from 0.6.0 to > 0.6.0

## v0.7.1 (2015-06-08)

* Fixed bug when listing clients

## v0.7.0 (2015-06-04)

* Add convenience methods to `G5Authenticatable::User`, as well as a
  `G5Updatable::ClientPolicy` for authorizing access to clients based on roles
  ([#37](https://github.com/G5/g5_authenticatable/pull/37))

## v0.6.0 (2015-06-02)

* Add support for resource-scoped roles
  ([#35](https://github.com/G5/g5_authenticatable/pull/35))

## v0.5.1 (2015-06-01)

* Upgraded dependency on
  [devise_g5_authenticatable](https://github.com/devise_g5_authenticatable) to
  pick up compatibility fixes for devise v3.5.1
  ([#34](https://github.com/G5/g5_authenticatable/issues/34))
* Removed custom `G5Authenticatable::FailureApp`, as the fix to devise itself
  was released ([#25](https://github.com/G5/g5_authenticatable/issues/25))

## v0.5.0 (2015-05-21)

* Added user roles. Requires running `rails g g5_authenticatable:install` and
  `rake db:migrate`
  ([#33](https://github.com/G5/g5_authenticatable/pull/33))
* Added user attributes. Requires running `rails g g5_authenticatable:install`
  and `rake db:migrate`
  ([#32](https://github.com/G5/g5_authenticatable/pull/32))
* Updated documentation around test helper dependencies and incompatibilities
  ([#30](https://github.com/G5/g5_authenticatable/pull/30))

## v0.4.2 (2015-02-10)

* Override `Devise::FailureApp` with fix for compatibility with Rails 4.2
  ([#26](https://github.com/G5/g5_authenticatable/pull/26))

## v0.4.1 (2015-01-26)

* Fix test helpers when strict token validation is enabled during testing
  ([#24](https://github.com/G5/g5_authenticatable/pull/24))

## v0.4.0 (2015-01-20)

* Several fixes around sign-out, including accepting GET requests and
  enabling strict token validation
  ([#21](https://github.com/G5/g5_authenticatable/pull/21))
* Improved documentation around controller test helpers
  ([#22](https://github.com/G5/g5_authenticatable/pull/22))
* Added `g5_authenticatable:purge_users` rake task to purge local user data;
  primarily used for configuring demo/dev environments built on a production
  clone or DB dump
  ([#23](https://github.com/G5/g5_authenticatable/pull/23))

## v0.3.0 (2014-03-13)

* First open source release to [RubyGems](https://rubygems.org)

## v0.2.0 (2014-03-11)

* Controller test helpers

## v0.1.4 (2014-03-07)

* Update dependency on [g5_authenticatable_api](https://github.com/G5/g5_authenticatable_api)
  for bug fix to ignore password credential configuration during token validation.

## v0.1.3 (2014-03-06)

* Remove auth client defaults in favor of env variables

## v0.1.2 (2014-03-05)

* Set `G5_AUTH_USERNAME` and `G5_AUTH_PASSWORD` on auth client defaults

## v0.1.0 (2014-02-26)

* Update dependency on [g5_authenticatable_api](https://github.com/G5/g5_authenticatable_api)
  to include new Rails API helpers.
* Fix shared test helpers for client applications that do not mixin the FactoryGirl syntax methods
  in their RSpec config.

## v0.0.4 (2014-02-20)

* Integrate [g5_authenticatable_api](https://github.com/G5/g5_authenticatable_api)
  for securing API methods.

## v0.0.3 (2014-02-13)

* Test helpers and shared context for integration tests in client applications.

## v0.0.2 (2014-02-10)

* Bump version for [devise_g5_authenticatable](https://github.com/G5/devise_g5_authenticatable)
  to pick up PostgreSQL fix.

## v0.0.1 (2014-02-07)

* Initial release
