require 'uri'
require 'net/http'
require 'json'
require 'openssl'

class DepartmentApi
  def initialize(access_token)
    @access_token = access_token
  end

  def get_departments_info(department_name)
    url = URI("https://gw.api.it.umich.edu/um/bf/Department/v2/DeptData?DeptDescription=#{URI.encode_www_form_component(department_name)}")
    response_json = make_http_request(url)

    if response_json.is_a?(Hash) && response_json['DepartmentList']
      {'success' => true, 'data' => response_json['DepartmentList']}
    else
      error_message = response_json['errorMessage'] || "Unknown error"
      {'success' => false, 'errorcode' => response_json['errorCode'] || "Unknown", 'error' => error_message}
    end
  rescue StandardError => e
    {'success' => false, 'errorcode' => "Exception", 'error' => e.message}
  end

  private

  def make_http_request(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = Rails.application.credentials.um_api[:buildings_client_id]
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    JSON.parse(response.body)
  end
end