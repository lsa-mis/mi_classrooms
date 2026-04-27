class ApiUpdateLog < ApplicationRecord
  STRUCTURED_REPORT_MARKER = "Structured report:".freeze

  def self.latest
    order(created_at: :desc).first
  end

  def structured_report
    return nil unless result.to_s.include?(STRUCTURED_REPORT_MARKER)

    json = result.to_s.split(STRUCTURED_REPORT_MARKER, 2).last.to_s.strip
    JSON.parse(json)
  rescue JSON::ParserError
    nil
  end

  def summary_text
    result.to_s.split(STRUCTURED_REPORT_MARKER, 2).first.to_s.strip
  end

  def structured_report?
    structured_report.present?
  end
end
