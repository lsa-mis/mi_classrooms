class DepartmentApi

  def initialize(access_token)
    @result = {'success' => false, 'errorcode' => '', 'error' => '', 'data' => {}}
    @access_token = access_token
  end

  def get_departments_info(dept_name)
    begin 
      url = URI("https://gw.api.it.umich.edu/um/bf/Department/v2/DeptData?DeptDescription=#{dept_name}")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
      request["authorization"] = "Bearer #{@access_token}"
      request["accept"] = 'application/json'

      response = http.request(request)
      response_json = JSON.parse(response.read_body)
      if response.code == "200"
        @result['success'] = true
        @result['data'] = response_json['DepartmentList']
      else
        if response_json['errorCode'].present?
          @result['errorcode'] = response_json['errorCode']
          @result['error'] = response_json['errorMessage']
        else 
          @result['errorcode'] = "Unknown error"
        end
      end
    rescue StandardError => e
      @result['errorcode'] = "Exception"
      @result['error'] = e.message
    end
    return @result
  end
  
end