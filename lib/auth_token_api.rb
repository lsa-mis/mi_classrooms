class AuthTokenApi
  def initialize(type, scope)
    @access_token = nil
    @type = type
    @scope = scope
  end

  def get_auth_token
    puts "in get auth token"
    begin
      url = URI("https://apigw.it.umich.edu/um/#{@type}/oauth2/token")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/x-www-form-urlencoded'
      request["accept"] = 'application/json'
      request.body = "grant_type=client_credentials&client_id=#{Rails.application.credentials.um_api[:buildings_client_id]}&client_secret=#{Rails.application.credentials.um_api[:buildings_client_secret]}&scope=#{@scope}"

      response = http.request(request)
      return @access_token = JSON.parse(response.read_body)['access_token']
      rescue => @error
        puts @error.inspect
      return false
    end
  end
end