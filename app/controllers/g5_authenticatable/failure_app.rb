# frozen_string_literal: true

module G5Authenticatable
  # Custom failure app that generates urls correctly within an isolated engine
  # https://github.com/plataformatec/devise/issues/4127
  class FailureApp < Devise::FailureApp
    def scope_url
      opts  = {}
      route = :"new_#{scope}_session_url"
      opts[:format] = request_format unless skip_format?

      config = Rails.application.config

      if config.try(:relative_url_root)
        opts[:script_name] = config.relative_url_root
      end

      failure_url(route, opts)
    end

    private

    def failure_url(route, opts)
      context = send(Devise.available_router_name)

      if context.respond_to?(route)
        context.send(route, opts)
      elsif respond_to?(:root_url)
        root_url(opts)
      else
        '/'
      end
    end
  end
end
