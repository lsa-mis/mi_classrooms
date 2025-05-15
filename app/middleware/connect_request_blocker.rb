module MiClassrooms
  class ConnectRequestBlocker
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["REQUEST_METHOD"] == "CONNECT"
        [405, { "Content-Type" => "text/plain", "Connection" => "close", "Allow" => "GET, POST, PUT, DELETE, HEAD, OPTIONS" }, ["HTTP method CONNECT is not allowed"]]
      else
        @app.call(env)
      end
    end
  end
end