class BuildingsApi

  def initialize(access_token)
      @result = {'success' => false, 'error' => '', 'data' => {}}
      @access_token = access_token
  end

  # API to return list of campuses
  # We can add it if we need it

  def get_buildings_for_current_fiscal_year
    url = URI("https://apigw.it.umich.edu/um/bf/BuildingInfo")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['httpCode'].present?
      @result['error'] = response_json['httpMessage'] + ". " + response_json['moreInformation']
    else
      @result['success'] = true
      @result['data'] = response_json
    end
    return @result

  end

  def get_building_data_by_id(bldrecnbr)
    url = URI("https://apigw.it.umich.edu/um/bf/BuildingInfoById/#{bldrecnbr}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['httpCode'].present?
      @result['error'] = response_json['httpMessage'] + ". " + response_json['moreInformation']
    else
      @result['success'] = true
      @result['data'] = response_json
    end
    return @result
 
  end

  # API to get building data by Short Name
  # API to buildings info for Fiscal Year

  def get_building_classroom_data(bldrecnbr)
    url = URI("https://apigw.it.umich.edu/um/bf/RoomInfo/#{bldrecnbr}")
    puts "in get_building_room_data"
    puts url
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['httpCode'].present?
      @result['error'] = response_json['httpMessage'] + ". " + response_json['moreInformation']
    else
      @result['success'] = true
      building_data = []
      response_json['ListOfRooms']['RoomData'].each do |room|
        if room['RoomTypeDescription'] == 'Classroom'
          building_data << room
        end
      end
      @result['data'] = building_data
    end
    return @result

  end

  def get_building_classroom_data_for_fiscal_year(bldrecnbr, fiscal_year)
    url = URI("https://apigw.it.umich.edu/um/bf/RoomInfo/#{fiscal_year}/#{bldrecnbr}")
    puts "in get_building_room_data"
    puts url
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['httpCode'].present?
      @result['error'] = response_json['httpMessage'] + ". " + response_json['moreInformation']
    else
      @result['success'] = true

      building_data = []
      response_json['ListOfRooms']['RoomData'].each do |room|
        if room['RoomTypeDescription'] == 'Classroom'
          building_data << room
        end
      end
      @result['data'] = building_data
    end
    return @result
  end
  
end