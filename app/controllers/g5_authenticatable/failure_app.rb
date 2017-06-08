class G5Authenticatable::FailureApp < Devise::FailureApp
  def scope_url
    opts  = {}
    route = :"new_#{scope}_session_url"
    opts[:format] = request_format unless skip_format?

    config = Rails.application.config

    # See https://github.com/G5/g5_authenticatable/issues/25
    opts[:script_name] = config.relative_url_root if config.try(:relative_url_root)

    context = send(Devise.available_router_name)

    if context.respond_to?(route)
      context.send(route, opts)
    elsif respond_to?(:root_url)
      root_url(opts)
    else
      "/"
    end
  end
end
