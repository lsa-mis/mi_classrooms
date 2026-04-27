class ApiUpdateLog < ApplicationRecord
  STRUCTURED_REPORT_MARKER = "Structured report:".freeze
  PHASE_TIME_PATTERN = /\A(?<phase>.+) Time: (?<seconds>[\d.]+) seconds\z/.freeze
  COUNTS_PATTERN = /\ACounts: (?<counts>.+)\z/.freeze
  WARNING_PATTERN = /\AWarning: (?<warning>.+)\z/.freeze
  ERROR_PATTERN = /\AError: (?<error>.+)\z/.freeze

  def self.latest
    order(created_at: :desc).first
  end

  def report_for_display
    structured_report || legacy_report
  end

  def structured_report
    return nil unless result.to_s.include?(STRUCTURED_REPORT_MARKER)

    json = result.to_s.split(STRUCTURED_REPORT_MARKER, 2).last.to_s.strip
    JSON.parse(json)
  rescue JSON::ParserError
    parse_structured_fragment(json)
  end

  def summary_text
    result.to_s.split(STRUCTURED_REPORT_MARKER, 2).first.to_s.strip
  end

  def structured_report?
    structured_report.present?
  end

  private

  def parse_structured_fragment(json)
    return nil if json.blank?

    first_brace = json.index("{")
    last_brace = json.rindex("}")
    return nil if first_brace.nil? || last_brace.nil? || last_brace <= first_brace

    JSON.parse(json[first_brace..last_brace])
  rescue JSON::ParserError
    nil
  end

  def legacy_report
    lines = summary_text.lines.map { |line| line.strip }.reject(&:blank?)
    phase_records = []
    current_phase = nil

    lines.each do |line|
      if (match = line.match(PHASE_TIME_PATTERN))
        current_phase = {
          "phase" => match[:phase],
          "duration_seconds" => match[:seconds].to_f,
          "status" => "success",
          "counters" => {},
          "warnings" => [],
          "errors" => []
        }
        phase_records << current_phase
        next
      end

      next if current_phase.nil?

      if (counts_match = line.match(COUNTS_PATTERN))
        current_phase["counters"] = parse_legacy_counts(counts_match[:counts])
      elsif (warning_match = line.match(WARNING_PATTERN))
        current_phase["warnings"] << warning_match[:warning]
      elsif (error_match = line.match(ERROR_PATTERN))
        current_phase["errors"] << error_match[:error]
        current_phase["status"] = "error"
      end
    end

    return nil if phase_records.empty?

    {
      "status" => status.to_s,
      "started_at" => created_at&.iso8601,
      "finished_at" => created_at&.iso8601,
      "duration_seconds" => nil,
      "phases" => phase_records
    }
  end

  def parse_legacy_counts(raw_counts)
    raw_counts.to_s.split(",").each_with_object({}) do |pair, counts|
      name, value = pair.strip.split("=", 2)
      next if name.blank?

      counts[name] = value.to_i
    end
  end
end
