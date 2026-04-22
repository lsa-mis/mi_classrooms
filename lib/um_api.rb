require "json"
require "net/http"
require "openssl"
require "uri"

module UmApi
  TOKEN_URL = "https://gw.api.it.umich.edu/um/oauth2/token".freeze
  CLIENT_ID_HEADER = "x-ibm-client-id".freeze
  AUTHORIZATION_HEADER = "authorization".freeze
  ACCEPT_HEADER = "accept".freeze
  CONTENT_TYPE_HEADER = "content-type".freeze
  JSON_MIME_TYPE = "application/json".freeze
  FORM_MIME_TYPE = "application/x-www-form-urlencoded".freeze

  class << self
    def token_store
      @token_store ||= TokenStore.new
    end

    def reset_token_store!
      @token_store = TokenStore.new
    end
  end

  class TokenStore
    EXPIRY_BUFFER_SECONDS = 60

    def initialize
      @cache = {}
      @mutex = Mutex.new
    end

    def fetch(scope)
      scope_key = scope.to_s
      cached_token = @mutex.synchronize { @cache[scope_key] }
      return token_result(cached_token[:access_token]) if token_valid?(cached_token)

      refresh(scope_key)
    rescue => e
      failure_result(e.inspect)
    end

    def clear
      @mutex.synchronize { @cache.clear }
    end

    private

    def refresh(scope)
      response = Connection.new.post_form(
        TOKEN_URL,
        form_data: {
          grant_type: "client_credentials",
          client_id: credentials[:buildings_client_id],
          client_secret: credentials[:buildings_client_secret],
          scope: scope
        },
        include_bearer: false,
        include_client_id: false
      )

      access_token = response.dig("data", "access_token")
      return failure_result(response["error"]) unless response["success"] && access_token.present?

      @mutex.synchronize do
        @cache[scope] = {
          access_token: access_token,
          expires_at: expires_at(response.dig("data", "expires_in"))
        }
      end

      token_result(access_token)
    end

    def expires_at(expires_in)
      seconds = expires_in.to_i
      return Time.current if seconds <= 0

      Time.current + [seconds - EXPIRY_BUFFER_SECONDS, 0].max
    end

    def token_valid?(cached_token)
      cached_token.present? &&
        cached_token[:access_token].present? &&
        cached_token[:expires_at].present? &&
        cached_token[:expires_at] > Time.current
    end

    def token_result(access_token)
      {"success" => true, "error" => "", "access_token" => access_token}
    end

    def failure_result(error)
      {
        "success" => false,
        "error" => error.presence || "Unknown error",
        "access_token" => nil
      }
    end

    def credentials
      Rails.application.credentials.um_api
    end
  end

  class Connection
    OK_CODE = "200".freeze
    DEFAULT_PAGE_SIZE = 1000

    def initialize(access_token: nil, scope: nil)
      @explicit_access_token = access_token
      @scope = scope&.to_s
      @token_error = nil
    end

    def get_json(url, query: nil, headers: {})
      uri = build_uri(url, query)
      request = Net::HTTP::Get.new(uri)
      request_json(uri, request, headers: headers)
    end

    def post_form(url, form_data:, query: nil, headers: {}, include_bearer: true, include_client_id: true)
      uri = build_uri(url, query)
      request = Net::HTTP::Post.new(uri)
      request[CONTENT_TYPE_HEADER] = FORM_MIME_TYPE
      request.body = URI.encode_www_form(normalize_query(form_data))
      request_json(
        uri,
        request,
        headers: headers,
        include_bearer: include_bearer,
        include_client_id: include_client_id
      )
    end

    def paginated_get(url, collection_path:, query: {})
      normalized_query = normalize_query(query)
      page_size = normalized_query.delete("$count").to_i
      page_size = DEFAULT_PAGE_SIZE if page_size <= 0
      start_index = normalized_query.delete("$start_index").to_i
      records = []

      loop do
        response = get_json(
          url,
          query: normalized_query.merge("$start_index" => start_index, "$count" => page_size)
        )
        return response unless response["success"]

        records.concat(Array(dig_value(response["data"], collection_path)))
        break unless next_page?(response["headers"])

        start_index += page_size
      end

      success_result(records)
    end

    private

    def request_json(uri, request, headers:, include_bearer: true, include_client_id: true)
      request[ACCEPT_HEADER] = JSON_MIME_TYPE
      request[CLIENT_ID_HEADER] = credentials[:buildings_client_id] if include_client_id

      if include_bearer
        access_token = bearer_token
        return auth_failure_result unless access_token.present?

        request[AUTHORIZATION_HEADER] = "Bearer #{access_token}"
      end

      headers.each { |header, value| request[header] = value }

      response = http_for(uri).request(request)
      response_body = parse_json(response.body.to_s)

      if response.code == OK_CODE
        success_result(response_body, headers: response.to_hash)
      else
        failure_result(
          extract_error_code(response_body),
          extract_error_message(response_body),
          response_body,
          response.to_hash
        )
      end
    rescue => e
      failure_result("Exception", e.message)
    end

    def bearer_token
      return @explicit_access_token if @explicit_access_token.present?
      return nil if @scope.blank?

      token_result = UmApi.token_store.fetch(@scope)
      return token_result["access_token"] if token_result["success"]

      @token_error = token_result["error"]
      nil
    end

    def auth_failure_result
      failure_result("AuthTokenError", @token_error.presence || "Could not fetch access token")
    end

    def http_for(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.min_version = OpenSSL::SSL::TLS1_2_VERSION if defined?(OpenSSL::SSL::TLS1_2_VERSION)
      end
      http
    end

    def build_uri(url, query)
      uri = URI.parse(url)
      merged_query = existing_query(uri).merge(normalize_query(query))
      uri.query = URI.encode_www_form(merged_query) if merged_query.present?
      uri
    end

    def existing_query(uri)
      return {} if uri.query.blank?

      URI.decode_www_form(uri.query).to_h
    end

    def normalize_query(query)
      return {} if query.blank?

      query.compact.to_h.transform_keys(&:to_s)
    end

    def parse_json(body)
      return {} if body.blank?

      JSON.parse(body)
    end

    def next_page?(headers)
      Array(headers["link"]).join(" ").include?("rel=next")
    end

    def dig_value(data, collection_path)
      Array(collection_path).reduce(data) do |memo, key|
        memo.is_a?(Hash) ? memo[key] : nil
      end
    end

    def extract_error_code(response_body)
      return response_body["errorCode"] if response_body.is_a?(Hash) && response_body["errorCode"].present?
      return "Fault" if response_body.is_a?(Hash) && response_body["fault"].present?

      "Unknown error"
    end

    def extract_error_message(response_body)
      return response_body["errorMessage"] if response_body.is_a?(Hash) && response_body["errorMessage"].present?
      return response_body.dig("fault", "faultstring") if response_body.is_a?(Hash) && response_body.dig("fault", "faultstring").present?
      return response_body["error"] if response_body.is_a?(Hash) && response_body["error"].present?

      "Unknown error"
    end

    def success_result(data, headers: {})
      {
        "success" => true,
        "errorcode" => "",
        "error" => "",
        "data" => data,
        "headers" => headers
      }
    end

    def failure_result(errorcode, error, data = {}, headers = {})
      {
        "success" => false,
        "errorcode" => errorcode,
        "error" => error.presence || "Unknown error",
        "data" => data,
        "headers" => headers
      }
    end

    def credentials
      Rails.application.credentials.um_api
    end
  end
end
