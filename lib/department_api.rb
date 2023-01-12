class DepartmentApi

  def initialize(access_token)
    @result = {'success' => false, 'error' => '', 'data' => {}}
    @access_token = access_token
  end

  def get_departments_info(dept_name)
    url = URI("https://gw.api.it.umich.edu/um/bf/Department/DeptData?deptDescr=#{dept_name}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    # if dept_name == "EH&S"
    #   puts response_json
    # end
    if response_json['ErrorResponse'].present?
      @result['success'] = false
      error = response_json['ErrorResponse']
      @result['error'] = error['responseCode'].to_s + ". " + error['responseDescription']
    else
      @result['success'] = true
      @result['data'] = response_json['DepartmentList']
    end
    # if dept_name == "EH&S"
    #   puts @result
    # end
    return @result
  end
  
end