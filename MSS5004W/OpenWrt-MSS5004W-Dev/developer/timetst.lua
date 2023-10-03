-- Get the current timestamp
local current_timestamp = os.time()

-- Add 3 hours in seconds (3 hours * 3600 seconds/hour)
local adjusted_timestamp = current_timestamp + 3 * 3600

-- Format the adjusted timestamp
local formatted_date = os.date("%d-%m-%Y %H:%M:%S", adjusted_timestamp)

print(formatted_date)
