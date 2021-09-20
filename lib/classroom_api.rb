class ClassroomApi

  def initialize(rmrecnbr, access_token)
    @rmrecnbr = rmrecnbr
    @classroom_data = {'result' => {'success' => false}, 'data' => {}}
    @access_token = access_token
  end

  def get_classroom_characteristics
    url = URI("https://apigw.it.umich.edu/um/aa/ClassroomList/Classrooms/#{@rmrecnbr}/Characteristics")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    @classroom_data = JSON.parse(response.read_body)
    
    puts @classroom_data 
  end

  def get_classroom_contact
    url = URI("https://apigw.it.umich.edu/um/aa/ClassroomList/Classrooms/#{@rmrecnbr}/Contacts")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    @classroom_data = JSON.parse(response.read_body)
    
    puts @classroom_data 
  end

end