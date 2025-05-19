module MiClassrooms
  class ConnectRequestHandler
    def initialize(app)
      @app = app
    end

    def call(env)
      if env['REQUEST_METHOD'] == 'CONNECT'
        # Return a 200 OK response for CONNECT requests
        [200, { 'Content-Type' => 'text/plain' }, ['Connection established']]
      else
        @app.call(env)
      end
    end
  end
end
