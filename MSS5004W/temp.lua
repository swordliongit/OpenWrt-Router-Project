function Time.Get_currentTime()
    -- Sample current time in the format you provided
    local current_time_str = os.date("%c")

    -- Define a table to map month names to month numbers
    local months = {
        Jan = "01",
        Feb = "02",
        Mar = "03",
        Apr = "04",
        May = "05",
        Jun = "06",
        Jul = "07",
        Aug = "08",
        Sep = "09",
        Oct = "10",
        Nov = "11",
        Dec = "12"
    }

    -- Extract the date and time components
    local day, month, day_num, time, year = current_time_str:match("(%a+) (%a+) (%d+) (%d+:%d+:%d+) (%d+)")

    -- Convert the month name to a number
    local month_num = months[month]

    -- Parse the time components (hours, minutes, and seconds)
    local hours, minutes, seconds = time:match("(%d+):(%d+):(%d+)")

    -- Add 3 hours and 50 minutes
    hours = tonumber(hours) + 3
    minutes = tonumber(minutes) + 40

    -- Ensure minutes do not exceed 59 and handle carryover
    if minutes >= 60 then
        hours = hours + 1
        minutes = minutes - 60
    end

    -- Create a new time string with the adjusted time
    local new_time = string.format("%s.%s.%s %02d:%02d:%02d", day_num, month_num, year, hours, minutes, seconds)

    return new_time
end
