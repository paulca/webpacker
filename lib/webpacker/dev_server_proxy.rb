require "rack/proxy"

class Webpacker::DevServerProxy < Rack::Proxy
  def rewrite_response(response)
    status, headers, body = response
    headers.delete "transfer-encoding"
    headers.delete "content-length" if Webpacker.dev_server.https?
    response
  end

  def perform_request(env)
    if env["PATH_INFO"] =~ /#{public_output_uri_path}/ && Webpacker.dev_server.running?
      env["HTTP_HOST"] = Webpacker.dev_server.host_with_port
      env["rack.ssl_verify_none"] = true
      super(env)
    else
      @app.call(env)
    end
  end

  private
    def public_output_uri_path
      Webpacker.config.public_output_path.relative_path_from(Webpacker.config.public_path)
    end
end
