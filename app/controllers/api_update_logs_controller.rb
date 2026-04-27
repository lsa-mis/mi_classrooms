class ApiUpdateLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_api_update_log, only: [:show]

  def index
    @page_title = "API Update Summary"
    @latest_log = ApiUpdateLog.latest
    @api_update_logs = ApiUpdateLog.order(created_at: :desc).limit(14)
    authorize ApiUpdateLog
  end

  def show
    @page_title = "API Update Run"
  end

  private

  def set_api_update_log
    @api_update_log = ApiUpdateLog.find(params[:id])
    authorize @api_update_log
  end
end
