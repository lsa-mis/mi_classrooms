module ApiUpdateDatabase
  class Runner
    LOG_FILE = "#{Rails.root}/log/api_nightly_update_db.log".freeze
    PAUSE_SECONDS = 61

    Phase = Struct.new(
      :time_label,
      :failure_label,
      :api_factory,
      :method_name,
      :token_scope,
      :token_action_name,
      :token_error_heading,
      :after_success,
      :pause_after,
      keyword_init: true
    )

    PHASES = [
      Phase.new(
        time_label: "Update campus list",
        failure_label: "Campus updates failed.",
        api_factory: ->(options) { BuildingsApi.new(delete_dry_run: options[:delete_dry_run]) },
        method_name: :update_campus_list,
        token_scope: "buildings",
        token_action_name: "update_campus_list",
        token_error_heading: "Update Campuses"
      ),
      Phase.new(
        time_label: "Update buildings",
        failure_label: "Buildings updates failed.",
        api_factory: ->(options) { BuildingsApi.new(delete_dry_run: options[:delete_dry_run]) },
        method_name: :update_all_buildings,
        pause_after: true
      ),
      Phase.new(
        time_label: "Update Rooms",
        failure_label: "Rooms updates failed.",
        api_factory: ->(options) { BuildingsApi.new(delete_dry_run: options[:delete_dry_run]) },
        method_name: :update_rooms
      ),
      Phase.new(
        time_label: "Add FacilityID to Classrooms",
        failure_label: "Add FacilityID to Classroom updates failed.",
        api_factory: ->(options) { ClassroomApi.new(delete_dry_run: options[:delete_dry_run]) },
        method_name: :add_facility_id_to_classrooms,
        token_scope: "classrooms",
        token_action_name: "add_facility_id_to_classrooms",
        token_error_heading: "Add facility_id to Classrooms",
        pause_after: true
      ),
      Phase.new(
        time_label: "Update classroom characteristics",
        failure_label: "Classroom Characteristics updates failed.",
        api_factory: ->(options) { ClassroomApi.new(delete_dry_run: options[:delete_dry_run]) },
        method_name: :update_all_classroom_characteristics,
        after_success: -> { UpdateRoomCharacteristicsArrayJob.perform_now },
        pause_after: true
      ),
      Phase.new(
        time_label: "Update classroom contacts",
        failure_label: "Classroom Contacts updates failed.",
        api_factory: ->(options) { ClassroomApi.new(delete_dry_run: options[:delete_dry_run]) },
        method_name: :update_all_classroom_contacts
      )
    ].freeze

    def initialize(delete_dry_run: false, sleeper: ->(seconds) { sleep(seconds.seconds) })
      @delete_dry_run = delete_dry_run
      @sleeper = sleeper
      @log = ApiLog.new
      @task_result = TaskResultLog.new
      @phases = []
    end

    def run
      started_at = Time.current
      Rails.logger.info({event: "api_update_database.start", environment: Rails.env, delete_dry_run: @delete_dry_run}.to_json)

      PHASES.each do |phase|
        token_result = ensure_token(phase)
        unless token_result.success?
          @phases << token_result
          return finish(started_at)
        end

        result = run_phase(phase)
        @phases << result
        return finish(started_at) unless result.success?

        @sleeper.call(PAUSE_SECONDS) if phase.pause_after
      end

      finish(started_at)
    end

    private

    def ensure_token(phase)
      return PhaseResult.new("#{phase.time_label} token").finish unless phase.token_scope

      result = PhaseResult.new("#{phase.time_label} token")
      token = AuthTokenApi.new(phase.token_scope).get_auth_token
      return result.finish if token["success"]

      message = "No access_token. Error: #{token["error"]}"
      @log.api_logger.debug "get access token for #{phase.token_action_name}, error: #{message}"
      result.add_error("#{phase.token_error_heading}: #{message}")
      result.finish
    end

    def run_phase(phase)
      fallback_result = PhaseResult.new(phase.time_label)
      result = fallback_result
      api = phase.api_factory.call(delete_dry_run: @delete_dry_run)

      debug = api.public_send(phase.method_name)
      result = (api.respond_to?(:last_result) && api.last_result) ? api.last_result : fallback_result
      run_after_success(phase, result) unless debug
      result.finish

      puts "#{phase.time_label} Time: #{result.duration_seconds.round(2)} seconds"
      Rails.logger.info({
        event: "api_update_database.phase",
        phase: phase.time_label,
        seconds: result.duration_seconds.round(2),
        success: result.success?
      }.to_json)

      result.add_error("#{phase.failure_label} See the log file #{LOG_FILE} for errors") if debug && result.errors.empty?
      result
    rescue => e
      result.add_error("#{phase.failure_label} #{e.class}: #{e.message}")
      @log.api_logger.debug "#{phase.method_name}, error: #{e.class}: #{e.message}"
      result.finish
    end

    def run_after_success(phase, result)
      return if phase.after_success.nil?

      if @delete_dry_run
        result.add_warning("Skipped after-success job for #{phase.time_label} because delete dry run is enabled.")
      else
        phase.after_success.call
      end
    end

    def finish(started_at)
      result = RunResult.new(started_at: started_at, finished_at: Time.current, phases: @phases)
      @task_result.update_log(summary_message(result), !result.success?, result.to_h)
      Rails.logger.info({
        event: "api_update_database.complete",
        status: result.success? ? "success" : "error",
        total_seconds: result.duration_seconds.round(2)
      }.to_json)
      result
    end

    def summary_message(result)
      lines = ["Time report:"]
      result.phases.each do |phase|
        counters = phase.counters.select { |_name, value| value.positive? }
        lines << "#{phase.phase} Time: #{phase.duration_seconds.round(2)} seconds"
        lines << "  Counts: #{counters.map { |name, value| "#{name}=#{value}" }.join(", ")}" if counters.present?
        phase.warnings.each { |warning| lines << "  Warning: #{warning}" }
        phase.errors.each { |error| lines << "  Error: #{error}" }
        lines << " "
      end

      lines << "Total wall time: #{(result.duration_seconds / 60).round(2)} minutes"
      lines << "Delete dry run: #{@delete_dry_run}"
      lines.join("\r\n")
    end
  end
end
