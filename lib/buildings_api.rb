class BuildingsApi

  def initialize(bldrecnbr, access_token)
      @bldrecnbr = bldrecnbr
      @building_data = {'result' => {'success' => false}, 'data' => {}}
      @access_token = access_token
  end

  def get_building_data
    url = URI("https://apigw.it.umich.edu/um/bf/BuildingInfoById/#{@bldrecnbr}")
    puts "in get_building_data"
    puts url
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    @building_data = JSON.parse(response.read_body)

    puts @building_data 
  end

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
    data = JSON.parse(response.read_body)
    puts data['ListOfBldgs']['Buildings'].count
  end

  def get_building_room_data
    url = URI("https://apigw.it.umich.edu/um/bf/RoomInfo/#{@bldrecnbr}")
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
    data = JSON.parse(response.read_body)
    @building_data = []
    data['ListOfRooms']['RoomData'].each do |room|
      if room['RoomTypeDescription'] == 'Classroom'
        @building_data << room
      end
    end

    puts @building_data 
  end

  def get_building_room_data_for_fiscal_year
    url = URI("https://apigw.it.umich.edu/um/bf/RoomInfo/2021/#{@bldrecnbr}")
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
    data = JSON.parse(response.read_body)
    @building_data = []
    data['ListOfRooms']['RoomData'].each do |room|
      if room['RoomTypeDescription'] == 'Classroom'
        @building_data << room
      end
    end

    puts @building_data 
  end
  
end