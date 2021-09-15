class AuthTokenApi
  def initialize()
    @access_token = nil
  end

  def get_auth_token
    begin
      url = URI("https://apigw.it.umich.edu/um/bf/oauth2/token")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/x-www-form-urlencoded'
      request["accept"] = 'application/json'
      request.body = "grant_type=client_credentials&client_id=#{Rails.application.credentials.um_api[:tdx_client_id]}&client_secret=#{Rails.application.credentials.um_api[:tdx_client_secret]}&scope=tdxticket"

      response = http.request(request)
      return @access_token = JSON.parse(response.read_body)['access_token']
    rescue => @error
      puts @error.inspect
      return false
    end
  end
end

class BuildingsApi

  def initialize(search_field, access_token)
      @search_field = search_field
      @device_tdx = {'result' => {'success' => false}, 'data' => {}}
      @access_token = access_token
  end

  def get_device_data
    url = URI("https://apigw.it.umich.edu/um/it/48/assets/search")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:tdx_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["content-type"] = 'application/json'
    request["accept"] = 'application/json'
    request.body = "{\"SerialLike\":\"#{@search_field}\"}"

    response = http.request(request)
    asset_info = JSON.parse(response.read_body)
    # check if response is not empty and returns only one result
    if asset_info.present? && asset_info.count == 1
      @device_tdx['result']['success'] = true
      @device_tdx['data']['serial'] = asset_info[0]['SerialNumber']
      @device_tdx['data']['hostname'] = asset_info[0]['Name']

      @device_tdx['data']['building'] = asset_info[0]['LocationName']
      @device_tdx['data']['room'] = asset_info[0]['LocationRoomName']
      @device_tdx['data']['owner'] = asset_info[0]['OwningCustomerName']
      @device_tdx['data']['department'] = asset_info[0]['OwningDepartmentName']
      @device_tdx['data']['manufacturer'] = asset_info[0]['ManufacturerName']
      @device_tdx['data']['model'] = asset_info[0]['ProductModelName']
      asset_id = asset_info[0]['ID']

      # get attributes (to get a mac address) by asset_id
      url = URI("https://apigw.it.umich.edu/um/it/48/assets/#{asset_id}")

      request = Net::HTTP::Get.new(url)
      request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:tdx_client_id]}"
      request["authorization"] = "Bearer #{@access_token}"
      request["accept"] = 'application/json'

      response = http.request(request)
      asset_info = JSON.parse(response.read_body)

      if asset_info.present? 
        mac_info = asset_info['Attributes'].select {|attrib| attrib["Name"] == "MAC Address(es)"}
        if mac_info.empty?
          @device_tdx['data']['mac'] = "" 
        else 
          @device_tdx['data']['mac'] = mac_info[0]["Value"]
        end
      end
    elsif asset_info.present? && asset_info.count > 1
        @device_tdx['result']['more-then_one_result'] = "More than one result returned for serial or hostname [#{@search_field}]."
    else 
        @device_tdx['result']['device_not_in_tdx'] = "This device is not present in the TDX Assets database."
    end
    @device_tdx
  end
end