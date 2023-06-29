holiday_dates = [
  "2023-01-02", # New Year's Day (observed)
  "2023-05-29", # Memorial Day
  "2023-07-04", # Independence Day
  "2023-09-04", # Labor Day
  "2023-11-23", # Thanksgiving Day
  "2023-11-24", # Day after Thanksgiving
  "2023-12-25", # Christmas Day
  "2023-12-26", # Season Day
  "2023-12-27", # Season Day
  "2023-12-28", # Season Day
  "2023-12-29", # Season Day
  "2024-01-01",  # New Year’s Day
]

Rails.application.config.holidays = holiday_dates.map do |date|
  Date.strptime(date, "%Y-%m-%d")
end
