class ApiUpdateLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_api_update_log, only: [:show]

  def index
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @page_title = "API Update Summary"
    @latest_log = ApiUpdateLog.latest
    @api_update_logs = ApiUpdateLog.order(created_at: :desc).limit(14)
    @active_buildings_count = Building.where(visible: true).count
    @classroom_buildings_count = Room.classrooms.distinct.count(:building_bldrecnbr)
    @active_rooms_count = Room.where(visible: true).count
    @classroom_listings_count = Room.classrooms.count
    authorize ApiUpdateLog

    SentryMetrics.count("api_update_logs.index.load_count", value: 1, attributes: {controller: self.class.name})
    SentryMetrics.gauge(
      "api_update_logs.index.active_buildings",
      @active_buildings_count,
      unit: "none",
      attributes: {controller: self.class.name}
    )
    SentryMetrics.distribution(
      "api_update_logs.index.active_rooms",
      @active_rooms_count,
      unit: "none",
      attributes: {controller: self.class.name}
    )
  ensure
    elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000
    SentryMetrics.distribution(
      "api_update_logs.index.response_time",
      elapsed_ms,
      unit: "millisecond",
      attributes: {controller: self.class.name}
    )
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
