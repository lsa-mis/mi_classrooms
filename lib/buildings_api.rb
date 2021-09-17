class AuthTokenApi
  def initialize()
    @access_token = nil
  end

  def get_auth_token
    puts "in get auth token"
    begin
      url = URI("https://apigw.it.umich.edu/um/bf/oauth2/token")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/x-www-form-urlencoded'
      request["accept"] = 'application/json'
      # request.body = "grant_type=client_credentials&client_id=#{Rails.application.credentials.um_api[:tdx_client_id]}&client_secret=#{Rails.application.credentials.um_api[:tdx_client_secret]}&scope=tdxticket"
      request.body = "grant_type=client_credentials&client_id=378e3cfb-b8a3-4e83-a154-eb307b7d9618&client_secret=U2aI2dT4lM1hC8yL8iM2yR3dY5rT3sK4jS3qO5sX3hT6xK8jT2&scope=buildings"

      response = http.request(request)
      return @access_token = JSON.parse(response.read_body)['access_token']
      # return @access_token = JSON.parse(response.read_body)
      rescue => @error
        puts @error.inspect
      return false
    end
  end
end

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
    request["x-ibm-client-id"] = "378e3cfb-b8a3-4e83-a154-eb307b7d9618"
    request["authorization"] = "Bearer #{@access_token}"
    # request["content-type"] = 'application/json'
    request["accept"] = 'application/json'

    response = http.request(request)
    @building_data = JSON.parse(response.read_body)
    # check if response is not empty and returns only one result
    # if asset_info.present? && asset_info.count == 1
    
    puts @building_data 
  end

  def get_building_room_data
    url = URI("https://apigw.it.umich.edu/um/bf/RoomInfo/#{@bldrecnbr}")
    puts "in get_building_room_data"
    puts url
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "378e3cfb-b8a3-4e83-a154-eb307b7d9618"
    request["authorization"] = "Bearer #{@access_token}"
    # request["content-type"] = 'application/json'
    request["accept"] = 'application/json'

    response = http.request(request)
    data = JSON.parse(response.read_body)
    @building_data = []
    # puts data['ListOfRooms']['RoomData'].first['RoomTypeDescription']
    data['ListOfRooms']['RoomData'].each do |room|
      if room['RoomTypeDescription'] == 'Classroom'
        @building_data << room
      end
    end
    # check if response is not empty and returns only one result
    # if asset_info.present? && asset_info.count == 1
    
    puts @building_data 
  end
end