class DepartmentApi
  BASE_URL = "https://gw.api.it.umich.edu/um/bf/Department/v2".freeze

  def initialize(access_token = nil)
    @client = UmApi::Connection.new(access_token: access_token, scope: "department")
  end

  def get_departments_info(dept_name)
    response = @client.get_json("#{BASE_URL}/DeptData", query: { DeptDescription: dept_name })
    return response unless response["success"]

    success_result(response["data"]["DepartmentList"])
  end

  def get_all_departments_info
    @client.paginated_get("#{BASE_URL}/DeptData", collection_path: %w[DepartmentList DeptData])
  end

  private

  def success_result(data)
    { "success" => true, "errorcode" => "", "error" => "", "data" => data }
  end
end