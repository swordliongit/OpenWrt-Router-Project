Time = {}

function Time.Get_currentTime()
    -- Get the current time in seconds since the epoch
    local os_time = os.time()

    -- Add 3 hours (3 * 3600 seconds) to adjust for the timezone
    os_time = os_time + 3 * 3600

    -- Convert to a table to extract date and time components
    local time_table = os.date("*t", os_time)

    -- Adjust day, month, and year if adding 3 hours exceeds 24 hours
    if time_table.hour >= 24 then
        time_table.hour = time_table.hour - 24
        time_table.day = time_table.day + 1
    end

    -- Convert the adjusted time back to a date string in the desired format
    local new_time_str = string.format("%02d.%02d.%04d %02d:%02d:%02d",
        time_table.day, time_table.month, time_table.year,
        time_table.hour, time_table.min, time_table.sec)

    return "[" .. new_time_str .. "]"
end

print(Time.Get_currentTime())
